/* Responsive composition over the original registered Whizpee product surfaces. */
(function(){
  'use strict';
  const U=window.UI;if(!U)return;
  const phone=document.getElementById('phone'),screen=document.getElementById('phone-screen');
  if(!phone||!screen||window.WZResponsive)return;
  const params=new URLSearchParams(location.search),media=matchMedia('(prefers-color-scheme: dark)');
  const nav=[['P04','discover','Discover'],['P01','chat','Chats'],['P02','phone','Calls'],['P03','status','Status'],['P05','profile','Profile']];
  const conversations=new Set(['P14','P23','P47']);
  const chatRoutes=new Set(['P01','P12','P13','P14','P15','P16','P18','P19','P20','P21','P22','P23','P24','P25','P26','P27','P47','P48']);
  const callRoutes=new Set(['P02','P28','P33']);
  const profileRoutes=new Set(['P05','P65','P66','P67','P68','P69','P70','P71','P72','P73','P74','P75','P76','P77','P78','P79','P80']);
  const onboarding=new Set(['P06','P07','P08','P09','P10','P11']);
  const gridRoutes=new Set(['P04','P35','P36','P49','P52']);
  const wz={viewport:'auto',width:0,size:'phone',themeMode:params.get('theme')||'light',platform:params.get('platform')==='native'?'native':'web',contextOpen:false,toolsOpen:false,historyDepth:0,restoring:false,reviewBypass:false,lastSection:'P04',listScroll:{}};
  const esc=U.esc;
  const icon=(name,size=22)=>U.icon(name,size);
  U.persist=()=>{};
  const rail=document.createElement('nav');rail.className='wz-rail';rail.id='wz-rail';rail.setAttribute('aria-label','Main application navigation');
  const list=document.createElement('aside');list.className='wz-list-pane';list.id='wz-list-pane';list.setAttribute('aria-label','Section navigation');
  const context=document.createElement('aside');context.className='wz-context-pane';context.id='wz-context-pane';context.setAttribute('aria-label','Conversation details');
  phone.prepend(list);phone.prepend(rail);phone.append(context);
  const originalRender=U.render,originalGo=U.go,originalBack=U.back,originalOpen=U.open,originalClose=U.close;
  const originalReset=U.resetDemo;

  function currentSection(){
    const id=U.current,n=Number(id.slice(1));
    if(chatRoutes.has(id))return'P01';if(callRoutes.has(id)||n>=29&&n<=32)return'P02';
    if(id==='P03'||n>=37&&n<=46)return'P03';
    if(id==='P34')return U.state.storyMode==='contact'||U.state.storyMode==='own'?'P03':'P04';
    if(['P04','P35','P36'].includes(id))return'P04';return'P05';
  }
  function widthClass(){const w=Math.floor(phone.clientWidth||phone.getBoundingClientRect().width||innerWidth);wz.width=w;return w<600?'phone':w<1024?'medium':w<1440?'wide':'xl';}
  function fitViewport(){
    const presets={phone:{width:386,height:802},tablet:{width:820,height:1024},desktop:{width:1280,height:900},wide:{width:1600,height:1000}};
    const selected=presets[wz.viewport]||{},width=selected.width||Number(wz.viewport)||0;
    const device=document.querySelector('.device'),stage=document.querySelector('.stage');
    stage?.classList.toggle('wz-fit-preview',!!width);device.classList.toggle('wz-forced-viewport',!!width);
    const availableWidth=stage?.clientWidth||innerWidth,availableHeight=stage?.clientHeight||innerHeight;
    const defaultScale=width?Math.min(1,availableWidth/width):1;
    const height=selected.height||({320:640,386:802,430:900,768:1024}[width])||availableHeight/defaultScale;
    const scale=width?Math.min(1,availableWidth/width,availableHeight/height):1;
    device.style.setProperty('--wz-preview-width',width?width+'px':'none');device.style.setProperty('--wz-preview-height',height+'px');device.style.setProperty('--wz-preview-scale',String(scale));phone.style.width='100%';
    wz.logicalHeight=width?height:availableHeight;wz.previewScale=scale;
  }
  function isSplit(){return wz.size==='wide'||wz.size==='xl';}
  function infoRoute(){return U.current==='P23'?'P25':U.current==='P47'?'P48':'P15';}
  function railHTML(){const active=currentSection();return`<button class="wz-rail-logo" data-go="P04" aria-label="Whizpee home">${U.brandLogo?U.brandLogo(42):'<strong>W</strong>'}</button>${nav.map(([id,ic,label])=>`<button class="wz-rail-link ${active===id?'is-active':''}" data-go="${id}" title="${label}" aria-label="${label}" ${active===id?'aria-current="page"':''}>${icon(ic,24)}${id==='P01'?'<span class="wz-rail-badge">3</span>':''}<span class="wz-rail-label">${label}</span></button>`).join('')}<div class="wz-rail-spacer"></div><button class="wz-rail-link" data-go="P67" title="Settings" aria-label="Settings">${icon('settings',23)}</button><button class="wz-rail-link" data-wz-action="theme" title="Switch appearance" aria-label="Switch appearance">${icon(U.state.theme==='dark'?'image':'moon',23)}</button><button class="wz-rail-link" data-go="P05" title="${esc(U.state.profile.name)}" aria-label="Your profile">${U.avatar(U.state.profile.name,36)}</button>`;}
  function settingsHTML(){return U.header('Your account',{back:false})+`<div class="page-pad"><div class="wz-settings-user">${U.avatar(U.state.profile.name,52)}<h2 style="font-size:18px;margin:12px 0 5px">${esc(U.state.profile.name)}</h2><p class="caption">Manage your profile and preferences.</p></div></div>`+[
    ['P05','profile','Overview'],['P65','edit','Personal profile'],['P66','group','Business profile'],['P54','wallet','Wallet'],['P37','plus','Publishing'],['P49','status','My Publications'],['P67','settings','Settings'],['P68','shield','Privacy'],['P70','bell','Notifications'],['P71','moon','Appearance'],['P72','check','Permissions'],['P74','profile','Account'],['P75','help','Help & support']
  ].map(([id,ic,label])=>`<button class="app-row wz-settings-link ${U.current===id?'is-active':''}" data-go="${id}"><span class="row-icon">${icon(ic)}</span><span class="row-body"><span class="row-title">${label}</span></span>${icon('chevron',16)}</button>`).join('');}
  function renderList(kind){
    const prior=list.dataset.kind;if(prior)wz.listScroll[prior]=list.scrollTop;
    let html='';const savedType=U.state.chatType;
    if(kind==='settings')html=settingsHTML();else html=U.registry[kind]?.render({})||'';
    U.state.chatType=savedType;
    list.dataset.kind=kind;list.innerHTML=html;
    if(kind==='P01'){
      list.insertAdjacentHTML('beforeend',`<button class="button secondary wz-list-compose" data-go="P12">${icon('plus',18)}New conversation</button>`);
      list.querySelectorAll('[data-act="c.openChat"]').forEach(el=>{
        const k=el.dataset.kind||'direct';let active=false;
        if(k==='group')active=U.current==='P23'||U.current==='P25';else if(k==='business')active=U.current==='P47'||U.current==='P48';else active=['P14','P15'].includes(U.current)&&el.dataset.value===U.state.contact;
        el.classList.toggle('is-active',active);if(active)el.setAttribute('aria-current','true');
      });
    }
    list.scrollTop=wz.listScroll[kind]||0;decorateWeb(list);
  }
  function placeholder(section){const v=section==='P01'?['chat','Your conversations, together','Choose a conversation to continue, or start a new chat with a mutual contact.','Start a conversation','P12']:section==='P02'?['phone','Your call history','Choose a call to view its details. Audio and video calls are available in the mobile app.','Open your chats','P01']:['status','A moment worth sharing','Choose an update to view it here, or create a Status of your own.','Create a Status','P37'];return`<div class="screen-body"><div class="wz-empty-pane">${icon(v[0],54)}<h1>${v[1]}</h1><p>${v[2]}</p><button class="button secondary" data-go="${v[4]}">${v[3]}</button><span class="wz-empty-pill">${icon('lock',13)}&nbsp; Your private profile stays separate from Business interactions</span></div></div>`;}
  function drawContext(){
    context.innerHTML='';if(!conversations.has(U.current)||!wz.contextOpen||wz.size!=='xl')return;
    const id=infoRoute(),type=U.state.chatType,html=U.registry[id].render({});U.state.chatType=type;
    context.innerHTML=`<header class="wz-context-head"><h2>${id==='P25'?'Group info':id==='P48'?'Business info':'Contact info'}</h2><button class="icon-button" data-wz-action="close-info" aria-label="Close information panel">${icon('close',20)}</button></header>${html}`;
    context.querySelector('.comm-page>.app-header')?.remove();context.querySelector(':scope>.app-header')?.remove();decorateWeb(context);
  }
  function decorateWeb(root){
    if(wz.platform!=='web')return;
    root.querySelectorAll('[data-act="c.call"],[data-act="c.callAgain"],[data-act="c.newCall"],[data-act="o.contactCall"],[data-act="o.call"]').forEach(el=>{el.hidden=true;el.style.display='none';});
    if(root===screen&&['P02','P28','P33'].includes(U.current)&&!root.querySelector('.wz-web-notice')){
      const notice=document.createElement('div');notice.className='wz-web-notice';notice.textContent='Calls are available in the mobile app. Your call history is available here.';
      const target=root.querySelector('.comm-page')||root.querySelector('.screen-body');const header=target?.querySelector('.app-header');if(header)header.after(notice);else target?.prepend(notice);
    }
  }
  function decorateOverlay(){const root=document.querySelector('#overlay-host .overlay-root');if(root){root.dataset.wzOverlay=U.overlayId||'';if(U.overlayId==='S10'&&wz.size!=='phone')root.querySelector('.overlay-box')?.setAttribute('aria-modal','false');decorateWeb(root);}}
  function updateLayout(){
    wz.size=widthClass();const section=currentSection();wz.lastSection=section;
    phone.classList.remove('wz-phone','wz-medium','wz-wide','wz-xl');phone.classList.add('wz-'+wz.size);phone.classList.toggle('wz-web',wz.platform==='web');
    phone.dataset.wzPage=U.current;phone.dataset.wzWidth=String(wz.width);phone.dataset.wzPlatform=wz.platform;
    phone.classList.toggle('wz-onboarding',onboarding.has(U.current));
    screen.classList.toggle('wz-conversation-page',conversations.has(U.current));screen.classList.toggle('wz-story-page',U.current==='P34');screen.classList.toggle('wz-call-page',['P29','P30','P31','P32'].includes(U.current));screen.classList.toggle('wz-grid-page',gridRoutes.has(U.current));screen.classList.toggle('wz-profile-page',U.current==='P05');
    let master='';if(isSplit()){
      if(chatRoutes.has(U.current))master='P01';else if(callRoutes.has(U.current))master='P02';else if(U.current==='P03'||U.current==='P34'&&section==='P03')master='P03';
      else if(profileRoutes.has(U.current)&&U.current!=='P05'&&!['P79','P80'].includes(U.current))master='settings';
    }
    phone.classList.toggle('wz-master-detail',!!master);if(master)renderList(master);else{list.innerHTML='';delete list.dataset.kind;}
    const homePlaceholder=!!master&&['P01','P02','P03'].includes(U.current)&&!U.scenario;
    screen.classList.toggle('wz-home-placeholder',homePlaceholder);if(homePlaceholder)screen.innerHTML=placeholder(U.current);
    phone.classList.toggle('wz-has-context',!!master&&conversations.has(U.current)&&wz.contextOpen&&wz.size==='xl');
    rail.innerHTML=railHTML();drawContext();decorateWeb(screen);decorateOverlay();
    if(conversations.has(U.current)){
      const header=screen.querySelector('.comm-chat-head');
      if(header&&!header.querySelector('[data-wz-action="info"]'))header.insertAdjacentHTML('beforeend',`<button class="icon-button wz-info-toggle" data-wz-action="info" aria-label="${wz.contextOpen&&wz.size==='xl'?'Close':'Open'} conversation information" title="Conversation information">${icon('info',22)}</button>`);
    }
    screen.querySelector('.wz-info-toggle')?.setAttribute('aria-label',(wz.contextOpen&&wz.size==='xl'?'Close':'Open')+' conversation information');
    if(U.current==='P71')screen.querySelectorAll('[data-act="w.theme"]').forEach(el=>el.querySelector('.radio-dot')?.classList.toggle('checked',el.dataset.value===wz.themeMode));
    document.querySelectorAll('[data-wz-theme-select]').forEach(el=>el.value=wz.themeMode);
    document.querySelectorAll('[data-wz-viewport-select]').forEach(el=>el.value=String(wz.viewport));
    const label=document.getElementById('wz-size-label');if(label)label.textContent=wz.width+' px · '+(wz.size==='phone'?'Phone':wz.size==='medium'?'Tablet':wz.size==='wide'?'Desktop':'Wide desktop');
  }
  U.render=function(){const value=originalRender.apply(this,arguments);updateLayout();return value;};
  U.go=function(id,args={}){
    if(!wz.reviewBypass&&conversations.has(U.current)&&id===infoRoute()&&wz.size==='xl'){
      wz.contextOpen=true;drawContext();phone.classList.add('wz-has-context');return;
    }
    const oldURL=location.href,oldID=U.current;const result=originalGo.call(U,id,args);
    if(!wz.restoring&&oldID!==U.current){try{const nextURL=location.href;history.replaceState(history.state,'',oldURL);history.pushState({wz:true,id:U.current,params:args},'',nextURL);wz.historyDepth++;}catch{}}
    return result;
  };
  U.back=function(){if(U.overlayId)return originalClose.call(U);if(wz.contextOpen&&wz.size==='xl'&&conversations.has(U.current)){wz.contextOpen=false;phone.classList.remove('wz-has-context');context.innerHTML='';return;}if(wz.historyDepth>0){history.back();return;}return originalBack.call(U);};
  U.open=function(){const result=originalOpen.apply(U,arguments);decorateOverlay();return result;};
  U.close=function(){const result=originalClose.apply(U,arguments);return result;};
  U.setTheme=function(mode){wz.themeMode=['light','dark','system'].includes(mode)?mode:'light';U.state.theme=wz.themeMode==='system'?(media.matches?'dark':'light'):wz.themeMode;U.render();};
  U.actions['w.theme']=el=>U.setTheme(el.dataset.value||'light');
  U.resetDemo=function(){wz.contextOpen=false;wz.themeMode='light';const result=originalReset?.apply(U,arguments);U.persist=()=>{};return result;};
  window.addEventListener('popstate',event=>{wz.restoring=true;wz.historyDepth=Math.max(0,wz.historyDepth-1);wz.contextOpen=false;const id=event.state?.id||location.hash.slice(1)||'P04';if(U.registry[id])originalGo.call(U,id,event.state?.params||{});wz.restoring=false;});
  media.addEventListener('change',()=>{if(wz.themeMode==='system')U.setTheme('system');});

  const bar=document.createElement('div');bar.className='wz-review-bar';bar.innerHTML=`<div class="wz-review-brand">WHIZPEE<span>Responsive client reference · A</span></div><div class="wz-review-actions"><span id="wz-size-label"></span><select data-wz-viewport-select aria-label="Preview viewport"><option value="auto">Fit window</option><option value="phone">Phone · 386</option><option value="tablet">Tablet · 820</option><option value="desktop">Desktop · 1280</option><option value="wide">Wide · 1600</option></select><button data-wz-action="theme" aria-label="Switch appearance">${icon('moon',15)}</button><button class="wz-tools-button" data-wz-action="tools">Prototype tools</button></div>`;document.body.append(bar);
  const backdrop=document.createElement('div');backdrop.className='wz-tools-backdrop';backdrop.hidden=true;backdrop.dataset.wzAction='close-tools';document.body.append(backdrop);
  const tools=document.createElement('section');tools.className='wz-tools';tools.hidden=true;tools.setAttribute('role','dialog');tools.setAttribute('aria-modal','true');tools.setAttribute('aria-labelledby','wz-tools-title');
  tools.innerHTML=`<header class="wz-tools-header"><div><h2 id="wz-tools-title">Prototype tools</h2><p>Review all 80 pages, 44 overlays, and 130 scenarios. These controls are outside the customer interface.</p></div><button data-wz-action="close-tools" aria-label="Close prototype tools">${icon('close',22)}</button></header><div class="wz-tools-controls"><label>All scenarios<select id="wz-all-scenarios"><option value="">Choose a scenario…</option>${U.inventory.states.map(s=>`<option value="${s.id}">${s.id} · ${esc(s.name)} (${s.surface})</option>`).join('')}</select></label><label>Appearance<select data-wz-theme-select><option value="light">Light</option><option value="dark">Dark</option><option value="system">System</option></select></label><label>Viewport<select data-wz-viewport-select><option value="auto">Fit window</option><option value="phone">Phone · 386 × 802</option><option value="tablet">Tablet · 820 × 1024</option><option value="desktop">Desktop · 1280 × 900</option><option value="wide">Wide · 1600 × 1000</option></select></label><label>Platform capabilities<select id="wz-platform"><option value="web">Web · calls unavailable</option><option value="native">Mobile simulation · calls enabled</option></select></label></div><div class="wz-tools-content"></div><footer class="wz-tools-footer"><button data-wz-action="onboarding">Start onboarding</button><button data-reset>Reset demo</button><button data-wz-action="close-tools">Return to prototype</button></footer>`;
  const toolsContent=tools.querySelector('.wz-tools-content');const catalog=document.getElementById('catalog'),inspector=document.querySelector('.inspector');toolsContent.append(catalog,inspector);document.body.append(tools);
  let previousFocus=null;
  const api=window.WZResponsive={state:wz,setViewport(value){wz.viewport=value||'auto';fitViewport();U.render();return wz.width;},setTheme:mode=>U.setTheme(mode),setPlatform(value){wz.platform=value==='native'?'native':'web';document.getElementById('wz-platform').value=wz.platform;U.render();},openTools(){wz.toolsOpen=true;previousFocus=document.activeElement;tools.hidden=false;backdrop.hidden=false;tools.querySelector('button')?.focus();},closeTools(){wz.toolsOpen=false;tools.hidden=true;backdrop.hidden=true;previousFocus?.focus?.({preventScroll:true});},showInfo(value=true){if(!conversations.has(U.current))return;wz.contextOpen=!!value;U.render();},navigate(id,args={}){wz.reviewBypass=true;try{U.go(id,args);}finally{wz.reviewBypass=false;}},applyScenario(id){const item=U.inventory.states.find(s=>s.id===id);if(!item)return;wz.reviewBypass=true;try{originalGo.call(U,item.surface,{});const select=document.getElementById('scenario-select');select.value=id;select.dispatchEvent(new Event('change',{bubbles:true}));}finally{wz.reviewBypass=false;}},refresh:updateLayout};
  document.addEventListener('click',event=>{
    const custom=event.target.closest('[data-wz-action]');
    if(custom){event.preventDefault();event.stopImmediatePropagation();const a=custom.dataset.wzAction;if(a==='tools')api.openTools();else if(a==='close-tools')api.closeTools();else if(a==='theme')api.setTheme(U.state.theme==='dark'?'light':'dark');else if(a==='close-info')api.showInfo(false);else if(a==='info'){if(wz.size==='xl')api.showInfo(!wz.contextOpen);else api.navigate(infoRoute());}else if(a==='onboarding'){api.closeTools();api.navigate('P06');}return;}
    const el=event.target.closest('[data-go],[data-act],[data-sheet],[data-dialog],[data-review-overlay]');if(!el)return;
    if(tools.contains(el)&&el.dataset.go){event.preventDefault();event.stopImmediatePropagation();api.navigate(el.dataset.go);api.closeTools();return;}
    if(tools.contains(el)&&el.dataset.reviewOverlay){wz.reviewBypass=true;queueMicrotask(()=>{wz.reviewBypass=false;api.closeTools();});return;}
    if(wz.platform==='web'&&!wz.reviewBypass&&!wz.toolsOpen){const act=el.dataset.act||'',id=el.dataset.go||'';if(['c.call','c.callAgain','c.newCall','c.answerCall','o.contactCall','o.call'].includes(act)||['P29','P30','P31','P32'].includes(id)){event.preventDefault();event.stopImmediatePropagation();U.toast('Audio and video calls are available in the mobile app.');return;}}
  },true);
  document.addEventListener('change',event=>{const el=event.target;if(el.matches('[data-wz-viewport-select]'))api.setViewport(el.value);else if(el.matches('[data-wz-theme-select]'))api.setTheme(el.value);else if(el.id==='wz-platform')api.setPlatform(el.value);else if(el.id==='wz-all-scenarios'){api.applyScenario(el.value);api.closeTools();}});
  document.addEventListener('keydown',event=>{
    if(event.key==='Escape'){if(wz.toolsOpen){event.preventDefault();event.stopImmediatePropagation();api.closeTools();}else if(U.overlayId){event.preventDefault();event.stopImmediatePropagation();U.close();}else if(wz.contextOpen){event.preventDefault();event.stopImmediatePropagation();api.showInfo(false);}}
    const modal=wz.toolsOpen?tools:document.querySelector('#overlay-host .overlay-box');if(event.key==='Tab'&&modal){const items=[...modal.querySelectorAll('button:not([disabled]),input,select,textarea,a[href],[tabindex="0"]')].filter(el=>!el.hidden&&el.getClientRects().length);if(items.length){const first=items[0],last=items.at(-1);if(event.shiftKey&&document.activeElement===first){event.preventDefault();last.focus();}else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus();}}}
  },true);
  if(params.get('presentation')==='1')document.body.classList.add('wz-presentation');
  if(typeof ResizeObserver!=='undefined')new ResizeObserver(()=>{const next=widthClass();if(next!==wz.size)U.render();else updateLayout();}).observe(phone);
  window.addEventListener('resize',()=>{fitViewport();U.render();});
  api.setViewport(params.get('viewport')||'auto');api.setTheme(wz.themeMode);api.setPlatform(wz.platform);
  const requestedSurface=params.get('surface');
  if(requestedSurface&&U.registry[requestedSurface])api.navigate(requestedSurface);
  else if(requestedSurface&&U.overlayRegistry[requestedSurface]){
    const row=U.inventory.rows.find(r=>r.id===requestedSurface);const page=row?.feature==='Wallet'?'P54':row?.feature==='Groups'?'P25':row?.feature==='Business conversations'?'P47':row?.feature==='Publishing'?'P44':row?.feature==='Calls'?'P31':row?.feature==='Onboarding'?'P07':row?.feature==='Profile and settings'?'P68':row?.feature==='Safety'?'P15':'P14';
    api.navigate(page);U.open(requestedSurface,{member:'John Davis',name:'John Davis',review:true});
  }
  if(params.get('scenario'))api.applyScenario(params.get('scenario'));
  if(params.get('info')==='1'&&conversations.has(U.current))api.showInfo(true);
  if(params.get('inspect')==='1')api.openTools();
})();
