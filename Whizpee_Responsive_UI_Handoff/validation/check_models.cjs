/* Isolated runtime tests. This is not a browser or a visual layout test. */
const fs = require('fs');
const vm = require('vm');
const path = require('path');
const root = path.resolve(__dirname, '..');
const finalPath = path.join(root, 'Whizpee_Responsive_Prototype.html');
const finalHtml = fs.existsSync(finalPath) ? fs.readFileSync(finalPath, 'utf8') : null;
const embedded = id => JSON.parse(finalHtml.match(new RegExp('<script[^>]*id="'+id+'"[^>]*>([\\s\\S]*?)</script>'))[1]);
const inventory = finalHtml ? embedded('whizpee-inventory') : JSON.parse(fs.readFileSync(path.join(root, 'reference/whizpee-inventory.json'), 'utf8'));
const spec = finalHtml ? embedded('whizpee-design-spec') : JSON.parse(fs.readFileSync(path.join(root, 'reference/whizpee-design-spec.json'), 'utf8'));
const noop = () => {};
const ids = new Map();
function element(id = '') {
  return {
    id, dataset: {}, style: {setProperty: noop, removeProperty: noop}, classList: {add: noop, remove: noop, toggle: noop, contains: () => false},
    textContent: id === 'whizpee-inventory' ? JSON.stringify(inventory) : id === 'whizpee-design-spec' ? JSON.stringify(spec) : '',
    innerHTML: '', value: '', hidden: false, scrollTop: 0, clientWidth: 1440, clientHeight: 900,
    addEventListener: noop, removeEventListener: noop, querySelector: () => null, querySelectorAll: () => [],
    appendChild: noop, insertAdjacentHTML: noop, remove: noop, focus: noop, setAttribute: noop, getAttribute: () => null,
    getBoundingClientRect: () => ({width: 1440, height: 900, top: 0, left: 0, right: 1440, bottom: 900}), closest: () => null,
    append: noop, hasAttribute: () => false,
  };
}
const errors = [];
const intervals = new Map(); let timerId = 0;
const document = {
  getElementById: id => {if (!ids.has(id)) ids.set(id, element(id)); return ids.get(id);},
  querySelector: () => null, querySelectorAll: () => [], addEventListener: noop, removeEventListener: noop,
  createElement: () => element(), activeElement: element(), body: element(), documentElement: element(),
};
const location = {hash: '', search: '', pathname: '/', href: 'http://isolated.invalid/'};
const window = {document, location, history: {replaceState: noop, pushState: noop}, addEventListener: noop,
  removeEventListener: noop, matchMedia: () => ({matches: false, addEventListener: noop, removeEventListener: noop}),
  innerWidth: 1440, innerHeight: 900, getComputedStyle: () => ({getPropertyValue: () => ''}),
};
const sandbox = {window, document, location, console: {log: noop, warn: (...x) => errors.push(['warning', ...x]), error: (...x) => errors.push(['error', ...x])},
  structuredClone, Intl, Date, URL, URLSearchParams, JSON, Math, Object, String, Number, Boolean, Array, Set, Map, Promise,
  navigator: {clipboard: {writeText: async () => {}}},
  localStorage: {getItem: () => null, setItem: noop, removeItem: noop},
  setTimeout: () => ++timerId, clearTimeout: noop,
  setInterval: fn => {const id = ++timerId; intervals.set(id, fn); return id;}, clearInterval: id => intervals.delete(id),
  requestAnimationFrame: () => ++timerId, cancelAnimationFrame: noop,
};
window.setTimeout = sandbox.setTimeout; window.setInterval = sandbox.setInterval;
vm.createContext(sandbox);
let source = (finalHtml ? [...finalHtml.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/g)].find(m => !m[1].includes('application/json'))[2] : fs.readFileSync(path.join(root, 'reference/prototype-runtime.js'), 'utf8')).replace(/window\.UI\.boot\(\);\s*$/, '');
vm.runInContext(source, sandbox, {timeout: 10000});
const U = window.UI;
// Rendering is tested directly below. During transition tests avoid our inert DOM being mistaken for a browser.
U.persist = noop; U.render = noop; U.close = () => {U.overlayId = null;}; U.toast = noop;
U.go = (id, params = {}) => {U.current = id; U.params = params; U.overlayId = null;};
U.open = (id, params = {}) => {U.overlayId = id; U.overlayParams = params;};
const findings = [];
function test(name, fn) {try {fn(); findings.push({name, pass: true});} catch (e) {findings.push({name, pass: false, message: e.message});}}
function assert(condition, message) {if (!condition) throw new Error(message);}
function fresh() {U.resetDemo(); intervals.clear(); errors.length = 0;}
function run(action, data = {}) {assert(U.actions[action], 'Missing action ' + action); return U.run(action, data);}

test('All 80 pages, 21 sheets, 23 dialogs registered', () => {
  assert(Object.keys(U.registry).length === 80, 'Page count ' + Object.keys(U.registry).length);
  assert(Object.keys(U.overlayRegistry).filter(k => k.startsWith('S')).length === 21, 'Sheet count');
  assert(Object.keys(U.overlayRegistry).filter(k => k.startsWith('D')).length === 23, 'Dialog count');
  assert(inventory.states.length === 130, 'State count');
  for (const row of inventory.rows) assert((row.id[0] === 'P' ? U.registry : U.overlayRegistry)[row.id], 'Unregistered ' + row.id);
});
test('All registered page renderers return HTML without exceptions', () => {
  for (const [id, def] of Object.entries(U.registry)) {
    fresh(); U.current = id; const html = def.render({});
    assert(typeof html === 'string' && html.length > 20, id + ' returned no meaningful markup');
  }
});
test('All overlay renderers return structured content', () => {
  for (const [id, render] of Object.entries(U.overlayRegistry)) {
    fresh(); const result = render({member: 'John Davis', name: 'John Davis', review: true});
    assert(result && typeof result.body === 'string', id + ' missing body');
  }
});
test('All130 named scenario fixture target renderers execute without exceptions', () => {
  const failures=[];
  for(const scenario of inventory.states){
    fresh();
    try{
      U.applyScenario(scenario.id);
      assert(U.scenario?.id===scenario.id,'Scenario not selected');
      const html=U.registry[scenario.surface].render({});
      assert(typeof html==='string'&&html.length>20,'No scenario target markup');
      assert(!errors.some(x=>x[0]==='error'),'Runtime error logged');
    }catch(e){failures.push(scenario.id+' '+e.message);}
  }
  assert(!failures.length,failures.join('; '));
});
test('Every seeded rendered action, page route and overlay points to a registered target', () => {
  const missing = new Set();
  const inspect = (html,id) => {
    for(const [,act] of html.matchAll(/data-act=["']([^"']+)/g)) if(!U.actions[act]) missing.add(id+' action '+act);
    for(const [,route] of html.matchAll(/data-go=["']([^"']+)/g)) if(!U.registry[route]) missing.add(id+' route '+route);
    for(const [,overlay] of html.matchAll(/data-(?:sheet|dialog)=["']([^"']+)/g)) if(!U.overlayRegistry[overlay]) missing.add(id+' overlay '+overlay);
  };
  for(const [id,def] of Object.entries(U.registry)){fresh();U.current=id;inspect(def.render({}),id);}
  for(const [id,render] of Object.entries(U.overlayRegistry)){fresh();const o=render({member:'John Davis',name:'John Davis',review:true});inspect((o.body||'')+(o.footer||''),id);}
  assert(!missing.size,[...missing].join('; '));
});
test('Payment confirmation credits once for stable provider reference', () => {
  fresh(); const before = U.state.credits;
  U.state.payment.amount = 100; U.state.payment.ref = 'qa-payment-100';
  run('w.confirmPayment'); run('w.confirmPayment');
  assert(U.state.credits === before + 100, 'Credits ' + U.state.credits);
  assert(U.state.confirmedPaymentRefs.filter(x => x === 'qa-payment-100').length === 1, 'Duplicate payment reference');
});
test('Business call ringing then cancelled charges zero', () => {
  fresh(); const before = U.state.credits; U.state.call.business = true; U.state.chatType = 'business';
  run('c.startCall', {value: 'audio', business: 'true'});
  assert(U.state.call.status === 'ringing', 'Expected ringing');
  run('c.endCall');
  assert(U.state.credits === before, 'Unanswered call charged');
  assert(!U.state.call.chargedBlocks, 'Unanswered charged blocks');
});
test('Answered paid audio call charges first block once; repeated End is safe', () => {
  fresh(); const before = U.state.credits; U.state.call.business = true; U.state.chatType = 'business';
  run('c.startCall', {value: 'audio', business: 'true'}); run('c.answerCall');
  assert(U.state.credits === before - 15, 'Expected first audio block');
  run('c.endCall'); const after = U.state.credits; run('c.endCall');
  assert(U.state.credits === after, 'Repeated end duplicated charge');
});
test('Active Business room opening does not charge twice', () => {
  fresh(); const before = U.state.credits;
  U.state.activeStory = {id: 'qa-room-story', name: 'Maison Studio', cover: 'interior', business: true};
  U.state.businessRoomActive = false;
  run('c.openBusiness'); const after = U.state.credits;
  run('c.openBusiness');
  assert(after === before - 10, 'First room charge wrong: ' + after);
  assert(U.state.credits === after, 'Second active-room open charged again');
});
test('Scenario V077 configures advertisement total as 155 Credits', () => {
  fresh(); U.applyScenario('V077');
  const markup = U.registry.P44.render({});
  assert(/class="p-summary-row total"><span>Total<\/span><strong>155 Credits<\/strong>/.test(markup), 'V077 kind=' + U.state.draft.kind + ' actual total=' + markup.match(/class="p-summary-row total">.{0,100}/)?.[0]);
});
test('Paid-category video advertisement review totals 155 Credits', () => {
  fresh(); U.state.draft = {...U.state.draft, categoryFee: 5, media: 'video', boost: true, kind: 'ad'};
  const markup = U.registry.P44.render({});
  assert(/class="p-summary-row total"><span>Total<\/span><strong>155 Credits<\/strong>/.test(markup), 'Review does not show actual 155 total');
});

test('Business room state stays separated by originating Story', () => {
  fresh(); const before = U.state.credits;
  const storyA = {id:'qa-story-a',name:'Maison Studio',cover:'interior',business:true};
  const storyB = {id:'qa-story-b',name:'Daily Brew',cover:'coffee',business:true};
  U.state.activeStory = storyA; run('c.openBusiness');
  U.state.activeStory = storyB; run('c.openBusiness');
  assert(U.state.credits === before - 20, 'Two different Story rooms not charged independently');
  U.state.activeStory = storyA; run('c.openBusiness');
  assert(U.state.credits === before - 20, 'Returning to active source Story charged again');
  assert(U.state.businessContextId === storyA.id && U.state.businessRoomActive, 'Wrong room restored');
  U.state.activeStory = {id:'qa-personal',name:'Sarah Wilson',business:false};
  U.syncBusinessRoom('P47');
  assert(U.state.activeStory.id === storyA.id && U.state.activeStory.business === true, 'Business identity leaked from personal Story');
});
test('Paid call stops at paid block boundary with insufficient next-block balance', () => {
  fresh(); U.state.credits = 15; U.state.chatType='business'; U.state.call.business=true;
  run('c.startCall',{value:'audio'}); run('c.answerCall');
  assert(U.state.credits===0,'First block did not consume available15');
  const tick=[...intervals.values()].at(-1); assert(tick,'No active mock interval');
  for(let i=0;i<60;i++) tick();
  assert(U.state.call.status==='ended','Call did not stop at boundary');
  assert(U.state.credits===0 && U.state.call.chargedBlocks===1,'Boundary overcharged');
  const entries=U.state.transactions.filter(t=>String(t.id).startsWith('TX-CALL-')).length;
  run('c.endCall');
  assert(U.state.transactions.filter(t=>String(t.id).startsWith('TX-CALL-')).length===entries,'Duplicate ledger entry after repeated End');
});
test('Diamond conversion debits available only and credits Cash once', () => {
  fresh(); U.state.conversionAmount = 100; const before = {diamonds: U.state.diamonds, cash: U.state.cash, pending: U.state.pendingDiamonds};
  run('w.reviewConversion'); run('w.convert'); run('w.convert');
  assert(U.state.diamonds === before.diamonds - 100, 'Diamond debit wrong');
  assert(U.state.cash === before.cash + 500, 'Cash credit wrong');
  assert(U.state.pendingDiamonds === before.pending, 'Pending Diamonds changed');
});
test('Withdrawal reserve and failure recredit happen once, including reopened request', () => {
  fresh(); const before = U.state.cash; U.state.withdraw.amount = 1000; U.state.withdraw.destination = '+237699123456';
  run('w.reviewWithdrawal'); run('w.withdraw'); run('w.withdraw');
  assert(U.state.cash === before - 1000, 'Withdrawal duplicate debit');
  run('w.payoutStatus', {value:'Failed'}); run('w.payoutStatus', {value:'Failed'});
  assert(U.state.cash === before, 'Failure duplicate recredit');
  const ref = U.state.withdraw.ref; run('w.openWithdrawal', {value:ref}); run('w.payoutStatus', {value:'Failed'});
  assert(U.state.cash === before, 'Reopened failure duplicate recredit');
});
console.log(JSON.stringify({kind: 'isolated-runtime', source: finalHtml ? 'assembled prototype first executable script' : 'reference source', tests: findings, consoleMessages: errors.map(x => x.map(v => String(v)))}, null, 2));
process.exitCode = findings.some(x => !x.pass) ? 1 : 0;
