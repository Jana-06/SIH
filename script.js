document.addEventListener('DOMContentLoaded', () => {
    const runButton = document.getElementById('run-button');
    const outputSummary = document.getElementById('output-summary');
    const imageDashboard = document.getElementById('image-dashboard');
    const loader = document.getElementById('loader');
    const chatbotFab = document.getElementById('chatbot-fab');
    const chatbotContainer = document.getElementById('chatbot-container');
    const closeChatbotBtn = document.getElementById('close-chatbot');
    const sendButton = document.getElementById('send-button');
    const toggleTTS = document.getElementById('toggle-tts');
    const userInput = document.getElementById('user-input');
    let analysisContext = ''; // Variable to store the full analysis context
    let ttsEnabled = false;

    // --- Main Analysis Logic ---
    runButton.addEventListener('click', () => {
        runButton.style.display = 'none';
        loader.style.display = 'block';
        outputSummary.innerHTML = '<p>Executing MATLAB script, please wait...</p>';
        imageDashboard.innerHTML = '';
        analysisContext = '';

        fetch('/run-matlab', { method: 'POST' })
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    let errorMsg = `<p>Error: ${data.error}</p>`;
                    if (data.details) {
                        errorMsg += `<pre>${data.details}</pre>`;
                    }
                    outputSummary.innerHTML = errorMsg;
                    imageDashboard.innerHTML = '<p>Analysis failed. No images to display.</p>';
                } else {
                    analysisContext = data.full_context;
                    parseAndDisplaySummary(analysisContext);
                    
                    if (data.images && data.images.length > 0) {
                        data.images.forEach(url => {
                            const imgContainer = document.createElement('div');
                            imgContainer.className = 'image-container';

                            const fileName = url.split('/').pop();
                            const cleanName = fileName.replace(/\.png$/i, '').replace(/_/g, ' ');
                            
                            const title = document.createElement('h3');
                            title.textContent = cleanName.replace(/(?:^|\s)\S/g, a => a.toUpperCase());

                            const img = document.createElement('img');
                            img.src = url;
                            img.alt = title.textContent;
                            
                            imgContainer.appendChild(title);
                            imgContainer.appendChild(img);
                            imageDashboard.appendChild(imgContainer);
                        });
                    } else {
                        imageDashboard.innerHTML = '<p>No visualization images were generated.</p>';
                    }
                }
            })
            .catch(error => {
                console.error('Fetch Error:', error);
                outputSummary.innerHTML = `<p>An unexpected error occurred: ${error.message}.</p>`;
                imageDashboard.innerHTML = '<p>An error prevented the analysis from completing.</p>';
            })
            .finally(() => {
                loader.style.display = 'none';
                runButton.style.display = 'inline-block';
            });
    });

    // --- Chatbot Interaction Logic ---
    chatbotFab.addEventListener('click', () => {
        chatbotContainer.classList.add('open');
    });

    closeChatbotBtn.addEventListener('click', () => {
        chatbotContainer.classList.remove('open');
    });

    if (toggleTTS) {
        toggleTTS.addEventListener('click', () => {
            ttsEnabled = !ttsEnabled;
            toggleTTS.classList.toggle('active', ttsEnabled);
        });
    }

    sendButton.addEventListener('click', () => {
        const message = userInput.value.trim();
        if (message) {
            addMessage(message, 'user');
            userInput.value = '';
            getBotResponse(message);
        }
    });

    userInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            sendButton.click();
        }
    });

    function addMessage(message, sender) {
        const messagesContainer = document.getElementById('chatbot-messages');
        const messageElement = document.createElement('div');
        messageElement.className = `message ${sender}-message`;
        messageElement.textContent = message;
        messagesContainer.appendChild(messageElement);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function getBotResponse(userMessage) {
        addMessage("Thinking...", 'bot-thinking');

        fetch('/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: userMessage,
                analysis_context: analysisContext
            }),
        })
        .then(response => response.json())
        .then(data => {
            const thinkingMessage = document.querySelector('.bot-thinking');
            if (thinkingMessage) thinkingMessage.remove();
            addMessage(data.reply, 'bot');
            if (ttsEnabled && window.speechSynthesis) {
                try {
                    const utter = new SpeechSynthesisUtterance(String(data.reply || ''));
                    utter.rate = 1.0; utter.pitch = 1.0; utter.volume = 1.0;
                    // Prefer an English voice if available
                    const voices = window.speechSynthesis.getVoices();
                    const en = voices.find(v => /en-/i.test(v.lang));
                    if (en) utter.voice = en;
                    window.speechSynthesis.speak(utter);
                } catch (e) { /* ignore TTS errors */ }
            }
        })
        .catch(error => {
            console.error('Chat Error:', error);
            const thinkingMessage = document.querySelector('.bot-thinking');
            if (thinkingMessage) thinkingMessage.remove();
            addMessage("Sorry, I'm having trouble connecting right now.", 'bot');
        });
    }

    function parseAndDisplaySummary(context) {
        outputSummary.innerHTML = ''; // Clear previous summary

        const sections = {
            'Crop Health': /CROP HEALTH ANALYSIS\s*====================([\s\S]*?)SOIL CONDITION ANALYSIS/,
            'Soil Condition': /SOIL CONDITION ANALYSIS\s*=======================([\s\S]*?)PEST RISK ANALYSIS/,
            'Pest Risk': /PEST RISK ANALYSIS\s*==================([\s\S]*?)RECOMMENDATIONS/
        };

        for (const [title, regex] of Object.entries(sections)) {
            const match = context.match(regex);
            if (match) {
                const categoryDiv = document.createElement('div');
                categoryDiv.className = 'summary-category';
                
                const header = document.createElement('h3');
                header.textContent = title;
                categoryDiv.appendChild(header);

                const content = match[1].trim().split('\n');
                content.forEach(line => {
                    line = line.trim();
                    if (line && !line.startsWith('===')) {
                        const parts = line.split(':');
                        if (parts.length > 1) {
                            const p = document.createElement('p');
                            const label = document.createElement('span');
                            label.className = 'label';
                            label.textContent = `${parts[0]}: `;
                            
                            const valueSpan = document.createElement('span');
                            const valueText = parts.slice(1).join(':').trim();
                            
                            // Check for status words to apply color
                            const statusMatch = valueText.match(/(\w+)/);
                            if (statusMatch) {
                                const statusClass = `status-${statusMatch[1].toLowerCase()}`;
                                valueSpan.classList.add(statusClass);
                            }
                            valueSpan.textContent = valueText;

                            p.appendChild(label);
                            p.appendChild(valueSpan);
                            categoryDiv.appendChild(p);
                        }
                    }
                });
                outputSummary.appendChild(categoryDiv);
            }
        }
    }
});
