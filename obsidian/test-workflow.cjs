const fs = require('fs');
const vm = require('vm');
const assert = require('assert/strict');
const src = require('path').join(__dirname, 'config/plugins/laguna-workflow/main.js');
const store = new Map();
let activeType = 'markdown';
let state = { type: 'markdown', state: { file: 'inbox/example.md', mode: 'source', source: false } };
let cursor = {line: 12, ch: 4};
const leaf = {view: {getViewType:()=>activeType,editor:{getCursor:()=>cursor,setCursor:c=>{cursor=c},focus(){}}},getViewState:()=>state,async setViewState(s){state=s;activeType=s.type},async openFile(f){state={type:'markdown',state:{file:f.path,mode:'source',source:false}}}};
class Plugin { addRibbonIcon(){} addCommand(){} }
const sandbox = {module:{exports:{}},require:(id)=>({Plugin,Modal:class{},Notice:class{},Setting:class{},normalizePath:x=>x,moment:()=>({format:f=>f==='YYYY-MM-DD'?'2026-09-04':'2026-09-04 120000'})}),window:{setTimeout},console};
vm.runInNewContext(fs.readFileSync(src,'utf8'),sandbox);
const p = new sandbox.module.exports();
p.app={vault:{getAbstractFileByPath:path=>store.get(path),async createFolder(path){store.set(path,{path})},async create(path,content){const f={path,extension:'md',content};store.set(path,f);return f}},workspace:{getMostRecentLeaf:()=>leaf,getLeaf:()=>leaf,setActiveLeaf(){}},commands:{executeCommandById(){throw Error('Unexpected history fallback')}}};
(async()=>{
 await p.onload();
 await p.createFreeformExperiment('test / run');
 const file=store.get('inbox/test - run.md');assert(file);assert.equal(file.content,'Date: 2026-09-04\n\n#experiment\n\n');
 await p.createFreeformExperiment('test / run');assert(store.has('inbox/test - run 2.md'));
 await p.createFreeformExperiment('');assert(store.has('inbox/Experiment 2026-09-04 120000.md'));
 cursor={line:12,ch:4};const before=JSON.stringify(state);await p.toggleGraph();assert.equal(activeType,'graph');await p.toggleGraph();assert.equal(JSON.stringify(state),before);assert.equal(cursor.line,12);
 console.log('Freeform creation, filename sanitization, collision handling, default naming, and graph/editor cursor restoration passed.');
})().catch(e=>{console.error(e);process.exit(1)});
