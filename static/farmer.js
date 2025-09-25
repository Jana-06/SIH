(function(){
  const runBtn = document.getElementById('run-button');
  const loader = document.getElementById('loader');
  // Chatbot elements
  const chatbotFab = document.getElementById('chatbot-fab');
  const chatbotContainer = document.getElementById('chatbot-container');
  const closeChatbotBtn = document.getElementById('close-chatbot');
  const sendButton = document.getElementById('send-button');
  const toggleTTS = document.getElementById('toggle-tts');
  const userInput = document.getElementById('user-input');

  let analysisContext = '';
  let ttsEnabled = false;

  function setLoading(loading){
    if(!runBtn||!loader) return;
    runBtn.disabled = loading;
    loader.style.display = loading ? 'inline-block' : 'none';
  }

  async function runAnalysis(){
    setLoading(true);
    try{
      const res = await fetch('/run-matlab', {method:'POST'});
      const data = await res.json();
      if(data.error){
        alert('Analysis failed: '+ (data.details || data.error));
        return;
      }

      analysisContext = data.full_context || '';

      // place images to 3 key slots: crop_health_map, ndvi_map, soil_condition_map
      const imgs = Array.isArray(data.images) ? data.images : [];
      function findImage(key){
        return imgs.find(u => u.toLowerCase().includes(key));
      }
      document.getElementById('img-health').src = findImage('crop_health_map') || findImage('health') || imgs[0] || '';
      document.getElementById('img-ndvi').src = findImage('ndvi_map') || findImage('ndvi') || '';
  document.getElementById('img-soil').src = findImage('soil_condition_map') || findImage('soil') || '';
  const pestMap = findImage('pest_risk_map') || findImage('pest') || '';
  const pestScoreMap = findImage('pest_risk_score_map') || '';
  const pestImgEl = document.getElementById('img-pest');
  if (pestImgEl) pestImgEl.src = pestMap || pestScoreMap;

      // parse key KPIs from console output
      const ctx = analysisContext;
      const healthStatus = (ctx.match(/Overall Health:\s*(\w+)\s*\(Score:\s*([0-9.]+)\)/i) || [])[1];
      const healthScore = (ctx.match(/Overall Health:\s*\w+\s*\(Score:\s*([0-9.]+)\)/i) || [])[1];
      const pestLevel   = (ctx.match(/Overall Risk:\s*(\w+)\s*\(Score:\s*([0-9.]+)\)/i) || [])[1];
      const pestScore   = (ctx.match(/Overall Risk:\s*\w+\s*\(Score:\s*([0-9.]+)\)/i) || [])[1];
      const soilMoist   = (ctx.match(/Moisture:\s*([0-9.]+)/i) || [])[1];

      document.getElementById('kpi-health').textContent = healthStatus || '—';
      document.getElementById('kpi-health-score').textContent = healthScore ? `Score: ${healthScore}` : '';
      document.getElementById('kpi-pest').textContent = pestLevel || '—';
      document.getElementById('kpi-pest-score').textContent = pestScore ? `Score: ${pestScore}` : '';
      document.getElementById('kpi-moisture').textContent = soilMoist ? `${soilMoist}` : '—';
      document.getElementById('kpi-moisture-hint').textContent = soilMoist ? 'Field average' : '';

      // Suggested actions in farmer-friendly wording
      const actions = [];

      // 1) Crop health triage
      if(healthStatus && /poor|fair|critical/i.test(healthStatus)) {
        actions.push('Check yellow/red areas on the Crop Health Map first — these zones need attention.');
      }

      // 2) Irrigation recommendation (depth in mm)
      // Assumes soil_moisture ~ 0..1 scale (volumetric proxy). Tunable thresholds.
      let irrMsg = '';
      if(soilMoist){
        const m = parseFloat(soilMoist);
        let depthMm = 0;
        if(m < 0.12) depthMm = 30;       // very dry
        else if(m < 0.18) depthMm = 20;  // dry
        else if(m < 0.25) depthMm = 10;  // slightly dry
        else depthMm = 0;                // adequate
        if(depthMm > 0){
          irrMsg = `Irrigation: apply about ${depthMm} mm of water (${depthMm} L/m²). For field area A hectares, water ≈ ${depthMm * 10} × A m³.`;
          actions.push(irrMsg);
        } else {
          actions.push('Irrigation: soil moisture is adequate; re-check in 2–3 days.');
        }
      }

      // 3) Pest treatment guidance
      // Parse a numeric pest score if present
      const pestScoreNum = pestScore ? parseFloat(pestScore) : NaN;
      let pestMsg = '';
      if(pestLevel){
        if(/high/i.test(pestLevel) || (!isNaN(pestScoreNum) && pestScoreNum >= 0.7)){
          pestMsg = 'Pest: HIGH risk — targeted spray in hotspot areas; treat ~40–60% of the field based on scouting.';
        } else if(/medium/i.test(pestLevel) || (!isNaN(pestScoreNum) && pestScoreNum >= 0.4)){
          pestMsg = 'Pest: MEDIUM risk — spot-spray confirmed patches; treat ~10–20% of the field.';
        } else {
          pestMsg = 'Pest: LOW risk — monitor twice weekly; use traps and thresholds before spraying.';
        }
        actions.push(pestMsg);
        // Provide a dosing formula (requires product label rate from user)
        actions.push('Spray guide: typically 200–300 L/ha of water. Product amount = label rate × treated area (ha). Calibrate the sprayer before use.');
      }

      if(actions.length===0) actions.push('No urgent issues detected. Continue routine monitoring.');

      const ul = document.getElementById('suggested-actions');
      ul.innerHTML = '';
      actions.forEach(a => { const li = document.createElement('li'); li.textContent = a; ul.appendChild(li); });

    }catch(err){
      console.error(err);
      alert('Failed to run analysis. Check server logs.');
    }finally{
      setLoading(false);
    }
  }

  if(runBtn) runBtn.addEventListener('click', runAnalysis);

  // --- Chatbot interactions (reuse server /chat) ---
  function addMessage(message, sender) {
    const messagesContainer = document.getElementById('chatbot-messages');
    const messageElement = document.createElement('div');
    messageElement.className = `message ${sender}-message`;
    messageElement.textContent = message;
    messagesContainer.appendChild(messageElement);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }

  function getBotResponse(userMessage) {
    addMessage('Thinking...', 'bot-thinking');
    fetch('/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: userMessage, analysis_context: analysisContext })
    })
    .then(r=>r.json())
    .then(data=>{
      const thinking = document.querySelector('.bot-thinking');
      if(thinking) thinking.remove();
      addMessage(data.reply || 'Please ask clearly, I will help.', 'bot');
      if (ttsEnabled && window.speechSynthesis) {
        try {
          const utter = new SpeechSynthesisUtterance(String(data.reply || ''));
          utter.rate = 1.0; utter.pitch = 1.0; utter.volume = 1.0;
          const voices = window.speechSynthesis.getVoices();
          const en = voices.find(v => /en-/i.test(v.lang));
          if (en) utter.voice = en;
          window.speechSynthesis.speak(utter);
        } catch(e) { /* ignore */ }
      }
    })
    .catch(()=>{
      const thinking = document.querySelector('.bot-thinking');
      if(thinking) thinking.remove();
      addMessage('Sorry, I am unable to connect right now.', 'bot');
    });
  }

  if(chatbotFab){
    chatbotFab.addEventListener('click', ()=> chatbotContainer.classList.add('open'));
  }
  if(closeChatbotBtn){
    closeChatbotBtn.addEventListener('click', ()=> chatbotContainer.classList.remove('open'));
  }
  if(toggleTTS){
    toggleTTS.addEventListener('click', ()=>{
      ttsEnabled = !ttsEnabled;
      toggleTTS.classList.toggle('active', ttsEnabled);
    });
  }
  if(sendButton){
    sendButton.addEventListener('click', ()=>{
      const msg = (userInput.value||'').trim();
      if(!msg) return;
      addMessage(msg, 'user');
      userInput.value='';
      getBotResponse(msg);
    });
  }
  if(userInput){
    userInput.addEventListener('keypress', e=>{ if(e.key==='Enter') sendButton.click(); });
  }
})();
