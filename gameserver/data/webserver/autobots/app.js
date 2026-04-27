/* ============================================================
   L2 Autobot Manager — SPA Application
   ============================================================ */

const BASE_URL = window.location.origin;
const RACES = ['Human', 'Elf', 'Dark Elf', 'Orc', 'Dwarf', 'Kamael'];
const SEXES = ['Male', 'Female'];
const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

let refreshTimer = null;
let currentRoute = '';

// ─── API Client ────────────────────────────────────────────

function getApiKey() { return localStorage.getItem('l2_api_key') || ''; }

async function api(method, path, body) {
    const key = getApiKey();
    if (!key) { showApiKeyModal(); throw new Error('No API key'); }
    const opts = {
        method,
        headers: { 'Content-Type': 'application/json', 'X-Api-Key': key }
    };
    if (body !== undefined) opts.body = JSON.stringify(body);
    try {
        const res = await fetch(BASE_URL + path, opts);
        if (res.status === 401) { toast('Unauthorized — check your API key', 'error'); throw new Error('401'); }
        if (res.status === 404) { toast('Resource not found', 'error'); throw new Error('404'); }
        if (!res.ok) {
            const txt = await res.text().catch(() => '');
            toast(`Error ${res.status}: ${txt || res.statusText}`, 'error');
            throw new Error(res.status);
        }
        const ct = res.headers.get('content-type') || '';
        return ct.includes('json') ? res.json() : res.text();
    } catch (e) {
        if (!['401', '404'].includes(e.message) && !e.message.match(/^\d+$/))
            toast('Network error — server unreachable', 'error');
        throw e;
    }
}

// ─── Toast ─────────────────────────────────────────────────

function toast(msg, type = 'success') {
    const el = document.createElement('div');
    el.className = `toast ${type}`;
    el.textContent = msg;
    document.getElementById('toast-container').appendChild(el);
    setTimeout(() => { el.classList.add('fadeOut'); setTimeout(() => el.remove(), 300); }, 3000);
}

// ─── Confirm dialog ────────────────────────────────────────

let confirmCb = null;
function showConfirm(title, message) {
    return new Promise(resolve => {
        document.getElementById('confirm-title').textContent = title;
        document.getElementById('confirm-message').textContent = message;
        document.getElementById('confirm-modal').style.display = '';
        confirmCb = resolve;
        document.getElementById('confirm-ok').onclick = () => { closeConfirm(); resolve(true); };
    });
}
function closeConfirm() {
    document.getElementById('confirm-modal').style.display = 'none';
    if (confirmCb) { confirmCb(false); confirmCb = null; }
}

// ─── API Key Modal ─────────────────────────────────────────

function showApiKeyModal() {
    document.getElementById('apikey-modal').style.display = '';
    const inp = document.getElementById('apikey-input');
    inp.value = getApiKey();
    setTimeout(() => inp.focus(), 100);
}
function saveApiKey() {
    const key = document.getElementById('apikey-input').value.trim();
    if (!key) return;
    localStorage.setItem('l2_api_key', key);
    document.getElementById('apikey-modal').style.display = 'none';
    toast('API key saved');
    checkConnection();
    route();
}

// ─── Connection check ──────────────────────────────────────

async function checkConnection() {
    try {
        await api('GET', '/api/server/status');
        document.getElementById('connection-status').className = 'status-indicator online';
        document.getElementById('conn-text').textContent = 'Connected';
    } catch {
        document.getElementById('connection-status').className = 'status-indicator offline';
        document.getElementById('conn-text').textContent = 'Disconnected';
    }
}

// ─── Router ────────────────────────────────────────────────

function route() {
    if (refreshTimer) { clearInterval(refreshTimer); refreshTimer = null; }
    const hash = location.hash.slice(1) || 'dashboard';
    currentRoute = hash;
    // highlight nav
    document.querySelectorAll('.nav-links a').forEach(a => {
        a.classList.toggle('active', a.getAttribute('data-route') === hash.split('/')[0]);
    });
    const view = document.getElementById('view');
    const base = hash.split('/')[0];
    const param = hash.split('/').slice(1).join('/');
    switch (base) {
        case 'dashboard': renderDashboard(view); break;
        case 'bots':      renderBotsList(view); break;
        case 'bot':        renderBotDetail(view, param); break;
        case 'create':     renderCreateBot(view); break;
        case 'scheduler':  renderScheduler(view); break;
        case 'trade':      renderTrade(view); break;
        case 'starterpack': renderStarterPack(view); break;
        case 'settings':   renderSettings(view); break;
        default:           renderDashboard(view); break;
    }
}

window.addEventListener('hashchange', route);

// ─── Helpers ───────────────────────────────────────────────

function h(tag, attrs, ...children) {
    const el = document.createElement(tag);
    if (attrs) Object.entries(attrs).forEach(([k, v]) => {
        if (k === 'className') el.className = v;
        else if (k.startsWith('on')) el.addEventListener(k.slice(2).toLowerCase(), v);
        else if (k === 'html') el.innerHTML = v;
        else el.setAttribute(k, v);
    });
    children.flat().forEach(c => {
        if (c == null) return;
        el.appendChild(typeof c === 'string' ? document.createTextNode(c) : c);
    });
    return el;
}

function loading() { return h('div', { className: 'loading-center' }, h('div', { className: 'spinner' })); }
function raceName(id) { return RACES[id] || `Race ${id}`; }
function sexName(id) { return SEXES[id] || `Sex ${id}`; }
function statusBadge(online) {
    return h('span', { className: `badge ${online ? 'badge-online' : 'badge-offline'}` }, online ? 'Online' : 'Offline');
}
function pad2(n) { return String(n).padStart(2, '0'); }

// ─── Dashboard ─────────────────────────────────────────────

async function renderDashboard(view) {
    view.innerHTML = '';
    view.append(
        h('div', { className: 'page-header' }, h('h2', null, 'Dashboard')),
        loading()
    );
    try {
        const status = await api('GET', '/api/server/status');
        view.innerHTML = '';
        // Stats
        const grid = h('div', { className: 'stats-grid' },
            statCard('Total Bots', status.totalBots, 'accent'),
            statCard('Online', status.onlineBots, 'success'),
            statCard('Offline', status.offlineBots, 'danger'),
            statCard('Uptime', formatUptime(status.uptimeSeconds), '')
        );
        // Quick actions
        const actions = h('div', { className: 'card' },
            h('div', { className: 'card-header' }, h('h3', null, 'Quick Actions')),
            h('div', { className: 'btn-group' },
                quickBtn('Spawn 10 Random', () => spawnRandom(10)),
                quickBtn('Spawn 25 Random', () => spawnRandom(25)),
                quickBtn('Spawn 50 Random', () => spawnRandom(50)),
                h('button', { className: 'btn btn-danger', onClick: despawnAll }, 'Despawn All')
            )
        );
        // Mini bot list
        const miniCard = h('div', { className: 'card' },
            h('div', { className: 'card-header' }, h('h3', null, 'Recently Online Bots')),
            loading()
        );
        view.append(
            h('div', { className: 'page-header' }, h('h2', null, 'Dashboard')),
            grid, actions, miniCard
        );
        // Load mini list
        try {
            const data = await api('GET', '/api/autobots?page=1&pageSize=5');
            const bots = (data.bots || []).filter(b => b.isOnline).slice(0, 5);
            miniCard.innerHTML = '';
            miniCard.append(h('div', { className: 'card-header' }, h('h3', null, 'Online Bots')));
            if (bots.length === 0) {
                miniCard.append(h('p', { className: 'text-muted', style: 'color:var(--text-muted);padding:8px 0;' }, 'No bots currently online.'));
            } else {
                const tbl = h('div', { className: 'table-wrap' },
                    h('table', null,
                        h('thead', null, h('tr', null,
                            h('th', null, 'Name'), h('th', null, 'Level'), h('th', null, 'Class'), h('th', null, 'Status')
                        )),
                        h('tbody', null, ...bots.map(b =>
                            h('tr', { style: 'cursor:pointer', onClick: () => location.hash = `#bot/${b.objId}` },
                                h('td', null, b.name),
                                h('td', null, String(b.level)),
                                h('td', null, String(b.classId)),
                                h('td', null, statusBadge(b.isOnline))
                            )
                        ))
                    )
                );
                miniCard.append(tbl);
            }
        } catch { miniCard.innerHTML = '<p style="color:var(--text-muted);padding:8px;">Could not load bot list.</p>'; }

        // Auto-refresh
        refreshTimer = setInterval(async () => {
            if (currentRoute !== 'dashboard') return;
            try {
                const s = await api('GET', '/api/server/status');
                grid.children[0].querySelector('.stat-value').textContent = s.totalBots;
                grid.children[1].querySelector('.stat-value').textContent = s.onlineBots;
                grid.children[2].querySelector('.stat-value').textContent = s.offlineBots;
                grid.children[3].querySelector('.stat-value').textContent = formatUptime(s.uptimeSeconds);
            } catch {}
        }, 10000);
    } catch {
        view.innerHTML = '<p style="color:var(--text-muted);padding:40px 0;">Failed to load dashboard. Check connection.</p>';
    }
}

function statCard(label, value, cls) {
    return h('div', { className: `stat-card ${cls}` },
        h('div', { className: 'stat-label' }, label),
        h('div', { className: 'stat-value' }, String(value))
    );
}
function quickBtn(text, fn) { return h('button', { className: 'btn btn-success', onClick: fn }, text); }
async function spawnRandom(count) {
    try { await api('POST', '/api/autobots/spawn-random', { count }); toast(`Spawned ${count} random bots`); route(); }
    catch {}
}
async function despawnAll() {
    if (!await showConfirm('Despawn All', 'Despawn ALL online bots?')) return;
    try { await api('POST', '/api/autobots/despawn-all'); toast('All bots despawned'); route(); }
    catch {}
}
function formatUptime(sec) {
    if (!sec && sec !== 0) return '—';
    const h = Math.floor(sec / 3600), m = Math.floor((sec % 3600) / 60);
    return `${h}h ${m}m`;
}

// ─── Bots List ─────────────────────────────────────────────

let botsPage = 1, botsPageSize = 20, botsFilter = '';
const selectedBots = new Set();

async function renderBotsList(view) {
    view.innerHTML = '';
    selectedBots.clear();
    const header = h('div', { className: 'page-header' },
        h('h2', null, 'Bot Management'),
        h('a', { href: '#create', className: 'btn btn-primary' }, '+ Create Bot')
    );
    const filterInput = h('input', { type: 'text', placeholder: 'Filter by name...', value: botsFilter });
    let debounce;
    filterInput.addEventListener('input', () => {
        clearTimeout(debounce);
        debounce = setTimeout(() => { botsFilter = filterInput.value; botsPage = 1; loadBots(); }, 300);
    });
    const pageSizeSel = h('select', null,
        ...[10, 20, 50].map(n => { const o = h('option', { value: n }, String(n)); if (n === botsPageSize) o.selected = true; return o; })
    );
    pageSizeSel.addEventListener('change', () => { botsPageSize = +pageSizeSel.value; botsPage = 1; loadBots(); });

    const bulkBar = h('div', { className: 'btn-group', style: 'margin-bottom:12px;' },
        h('button', { className: 'btn btn-sm btn-success', onClick: bulkSpawn }, 'Spawn Selected'),
        h('button', { className: 'btn btn-sm btn-warning', onClick: bulkDespawn }, 'Despawn Selected'),
        h('button', { className: 'btn btn-sm btn-danger', onClick: bulkDelete }, 'Delete Selected')
    );
    const toolbar = h('div', { className: 'toolbar' }, filterInput, h('span', { style: 'color:var(--text-muted);font-size:0.8rem' }, 'Page size:'), pageSizeSel);
    const tableWrap = h('div', null, loading());
    const paginationEl = h('div', { className: 'pagination' });
    view.append(header, toolbar, bulkBar, tableWrap, paginationEl);

    async function loadBots() {
        tableWrap.innerHTML = ''; tableWrap.append(loading());
        try {
            const q = `/api/autobots?page=${botsPage}&pageSize=${botsPageSize}` + (botsFilter ? `&name=${encodeURIComponent(botsFilter)}` : '');
            const data = await api('GET', q);
            const bots = data.bots || [];
            const total = data.total || 0;
            const pages = Math.max(1, Math.ceil(total / botsPageSize));
            tableWrap.innerHTML = '';
            // Select all checkbox
            const selAll = h('input', { type: 'checkbox' });
            selAll.addEventListener('change', () => {
                const cbs = tableWrap.querySelectorAll('tbody input[type="checkbox"]');
                cbs.forEach(cb => { cb.checked = selAll.checked; const id = cb.dataset.id; selAll.checked ? selectedBots.add(id) : selectedBots.delete(id); });
            });
            const tbody = h('tbody', null, ...bots.map(b => {
                const cb = h('input', { type: 'checkbox', 'data-id': String(b.objId) });
                if (selectedBots.has(String(b.objId))) cb.checked = true;
                cb.addEventListener('change', () => { cb.checked ? selectedBots.add(String(b.objId)) : selectedBots.delete(String(b.objId)); });
                return h('tr', null,
                    h('td', null, cb),
                    h('td', null, h('a', { href: `#bot/${b.objId}` }, b.name)),
                    h('td', null, String(b.level)),
                    h('td', null, String(b.classId)),
                    h('td', null, raceName(b.race)),
                    h('td', null, statusBadge(b.isOnline)),
                    h('td', { style: 'font-size:0.78rem;color:var(--text-muted)' }, `${b.x}, ${b.y}, ${b.z}`),
                    h('td', null,
                        h('div', { className: 'btn-group' },
                            h('button', { className: `btn btn-sm ${b.isOnline ? 'btn-warning' : 'btn-success'}`, onClick: async (e) => {
                                e.stopPropagation();
                                try {
                                    await api('POST', `/api/autobots/${b.objId}/${b.isOnline ? 'despawn' : 'spawn'}`);
                                    toast(b.isOnline ? `${b.name} despawned` : `${b.name} spawned`);
                                    loadBots();
                                } catch {}
                            }}, b.isOnline ? 'Despawn' : 'Spawn'),
                            h('button', { className: 'btn btn-sm btn-danger', onClick: async (e) => {
                                e.stopPropagation();
                                if (!await showConfirm('Delete Bot', `Delete "${b.name}" permanently?`)) return;
                                try { await api('DELETE', `/api/autobots/${b.objId}`); toast(`${b.name} deleted`); loadBots(); } catch {}
                            }}, 'Del')
                        )
                    )
                );
            }));
            if (bots.length === 0) {
                tableWrap.append(h('p', { style: 'color:var(--text-muted);padding:20px;text-align:center;' }, 'No bots found.'));
            } else {
                tableWrap.append(h('div', { className: 'table-wrap' },
                    h('table', null,
                        h('thead', null, h('tr', null,
                            h('th', null, selAll),
                            h('th', null, 'Name'), h('th', null, 'Lvl'), h('th', null, 'Class'),
                            h('th', null, 'Race'), h('th', null, 'Status'), h('th', null, 'Position'), h('th', null, 'Actions')
                        )),
                        tbody
                    )
                ));
            }
            // Pagination
            paginationEl.innerHTML = '';
            if (pages > 1) {
                const prevBtn = h('button', { className: 'btn btn-sm btn-secondary', disabled: botsPage <= 1, onClick: () => { botsPage--; loadBots(); } }, '\u25C0 Prev');
                const nextBtn = h('button', { className: 'btn btn-sm btn-secondary', disabled: botsPage >= pages, onClick: () => { botsPage++; loadBots(); } }, 'Next \u25B6');
                paginationEl.append(prevBtn, h('span', null, `Page ${botsPage} of ${pages} (${total} bots)`), nextBtn);
            } else {
                paginationEl.append(h('span', null, `${total} bot${total !== 1 ? 's' : ''}`));
            }
        } catch { tableWrap.innerHTML = '<p style="color:var(--text-muted);padding:20px;">Failed to load bots.</p>'; }
    }
    loadBots();

    async function bulkSpawn() {
        if (!selectedBots.size) return toast('No bots selected', 'error');
        for (const id of selectedBots) { try { await api('POST', `/api/autobots/${id}/spawn`); } catch {} }
        toast(`Spawned ${selectedBots.size} bots`); loadBots();
    }
    async function bulkDespawn() {
        if (!selectedBots.size) return toast('No bots selected', 'error');
        for (const id of selectedBots) { try { await api('POST', `/api/autobots/${id}/despawn`); } catch {} }
        toast(`Despawned ${selectedBots.size} bots`); loadBots();
    }
    async function bulkDelete() {
        if (!selectedBots.size) return toast('No bots selected', 'error');
        if (!await showConfirm('Bulk Delete', `Delete ${selectedBots.size} bots permanently?`)) return;
        for (const id of selectedBots) { try { await api('DELETE', `/api/autobots/${id}`); } catch {} }
        toast(`Deleted ${selectedBots.size} bots`); selectedBots.clear(); loadBots();
    }
}

// ─── Bot Detail ────────────────────────────────────────────

async function renderBotDetail(view, id) {
    view.innerHTML = ''; view.append(loading());
    try {
        const bot = await api('GET', `/api/autobots/${id}`);
        view.innerHTML = '';
        const prefs = bot.preferences || {};

        const headerEl = h('div', { className: 'detail-header' },
            h('h2', null, bot.name),
            statusBadge(bot.isOnline),
            h('button', { className: `btn ${bot.isOnline ? 'btn-warning' : 'btn-success'}`, onClick: async () => {
                try { await api('POST', `/api/autobots/${id}/${bot.isOnline ? 'despawn' : 'spawn'}`); toast(bot.isOnline ? 'Despawned' : 'Spawned'); renderBotDetail(view, id); } catch {}
            }}, bot.isOnline ? 'Despawn' : 'Spawn'),
            h('button', { className: 'btn btn-danger', onClick: async () => {
                if (!await showConfirm('Delete', `Delete "${bot.name}"?`)) return;
                try { await api('DELETE', `/api/autobots/${id}`); toast('Bot deleted'); location.hash = '#bots'; } catch {}
            }}, 'Delete'),
            h('a', { href: '#bots', className: 'btn btn-secondary' }, '\u25C0 Back')
        );

        const infoCard = h('div', { className: 'card' },
            h('div', { className: 'card-header' }, h('h3', null, 'Bot Information')),
            h('div', { className: 'detail-grid' },
                detailItem('Level', bot.level),
                detailItem('Class ID', bot.classId),
                detailItem('Race', raceName(bot.race)),
                detailItem('Sex', sexName(bot.sex)),
                detailItem('Position', `${bot.x}, ${bot.y}, ${bot.z}`),
                detailItem('Object ID', bot.objId)
            )
        );

        // Combat prefs
        const targeting = makeSelect('Targeting Preference', ['RANDOM', 'CLOSEST', 'WEAKEST'], prefs.targetingPreference || 'RANDOM');
        const attackType = makeSelect('Attack Player Type', ['NONE', 'ALL', 'FLAGGED', 'KARMA'], prefs.attackPlayerType || 'NONE');
        const targetRange = makeNumberInput('Targeting Range', prefs.targetingRange || 800, 100, 3000);
        const useHpPot = makeCheckbox('Use HP Potions', prefs.useHpPotions || false);
        const hpThresh = makeNumberInput('HP Potion Threshold %', prefs.hpPotionThreshold || 50, 1, 99);
        const useMpPot = makeCheckbox('Use MP Potions', prefs.useMpPotions || false);
        const mpThresh = makeNumberInput('MP Potion Threshold %', prefs.mpPotionThreshold || 50, 1, 99);

        const combatCard = h('div', { className: 'card' },
            h('div', { className: 'card-header' }, h('h3', null, 'Combat Preferences')),
            h('div', { className: 'form-row' }, targeting.group, attackType.group),
            h('div', { className: 'form-row' }, targetRange.group, h('div')),
            h('div', { className: 'form-row' }, useHpPot.group, hpThresh.group),
            h('div', { className: 'form-row' }, useMpPot.group, mpThresh.group)
        );

        // Social prefs
        const townAction = makeSelect('Town Action', ['NONE', 'SIT', 'WALK', 'TRADE'], prefs.townAction || 'NONE');
        const socialCard = h('div', { className: 'card' },
            h('div', { className: 'card-header' }, h('h3', null, 'Social Preferences')),
            townAction.group
        );

        // Activity prefs
        const respawnAction = makeSelect('Respawn Action', ['RETURN_TO_DEATH_LOC', 'TELEPORT_TO_TOWN', 'STAY_DEAD'], prefs.respawnAction || 'RETURN_TO_DEATH_LOC');
        const activityCard = h('div', { className: 'card' },
            h('div', { className: 'card-header' }, h('h3', null, 'Activity Preferences')),
            respawnAction.group
        );

        const saveBtn = h('button', { className: 'btn btn-primary', style: 'margin-top:8px;', onClick: async () => {
            saveBtn.disabled = true; saveBtn.textContent = 'Saving...';
            try {
                await api('PUT', `/api/autobots/${id}`, {
                    preferences: {
                        targetingPreference: targeting.value(),
                        attackPlayerType: attackType.value(),
                        targetingRange: +targetRange.value(),
                        useHpPotions: useHpPot.value(),
                        hpPotionThreshold: +hpThresh.value(),
                        useMpPotions: useMpPot.value(),
                        mpPotionThreshold: +mpThresh.value(),
                        townAction: townAction.value(),
                        respawnAction: respawnAction.value()
                    }
                });
                toast('Bot updated');
            } catch {}
            saveBtn.disabled = false; saveBtn.textContent = 'Save Changes';
        }}, 'Save Changes');

        view.append(headerEl, infoCard, combatCard, socialCard, activityCard, saveBtn);
    } catch { view.innerHTML = '<p style="color:var(--text-muted);padding:40px;">Failed to load bot details.</p>'; }
}

function detailItem(label, value) {
    return h('div', { className: 'detail-item' },
        h('div', { className: 'detail-label' }, label),
        h('div', { className: 'detail-value' }, String(value ?? '—'))
    );
}
function makeSelect(label, options, current) {
    const sel = h('select', null, ...options.map(o => { const opt = h('option', { value: o }, o); if (o === current) opt.selected = true; return opt; }));
    const group = h('div', { className: 'form-group' }, h('label', null, label), sel);
    return { group, value: () => sel.value };
}
function makeNumberInput(label, current, min, max) {
    const inp = h('input', { type: 'number', value: current, min, max });
    const group = h('div', { className: 'form-group' }, h('label', null, label), inp);
    return { group, value: () => inp.value };
}
function makeCheckbox(label, checked) {
    const cb = h('input', { type: 'checkbox' }); cb.checked = checked;
    const group = h('div', { className: 'form-group', style: 'display:flex;align-items:center;gap:8px;' }, cb, h('label', { style: 'margin:0' }, label));
    return { group, value: () => cb.checked };
}

// ─── Create Bot ────────────────────────────────────────────

function renderCreateBot(view) {
    view.innerHTML = '';
    const nameInp = h('input', { type: 'text', placeholder: 'Bot name', required: 'true' });
    const raceSel = h('select', null, ...RACES.map((r, i) => h('option', { value: i }, r)));
    const classInp = h('input', { type: 'number', value: '0', min: '0', placeholder: 'Class ID' });
    const sexSel = h('select', null, ...SEXES.map((s, i) => h('option', { value: i }, s)));
    const lvlInp = h('input', { type: 'number', value: '1', min: '1', max: '85' });

    const submitBtn = h('button', { className: 'btn btn-primary', onClick: async () => {
        const name = nameInp.value.trim();
        if (!name) return toast('Name is required', 'error');
        submitBtn.disabled = true; submitBtn.textContent = 'Creating...';
        try {
            const result = await api('POST', '/api/autobots', {
                name,
                race: +raceSel.value,
                classId: +classInp.value,
                sex: +sexSel.value,
                level: +lvlInp.value
            });
            toast(`Bot "${name}" created`);
            location.hash = result && result.objId ? `#bot/${result.objId}` : '#bots';
        } catch {}
        submitBtn.disabled = false; submitBtn.textContent = 'Create Bot';
    }}, 'Create Bot');

    view.append(
        h('div', { className: 'page-header' }, h('h2', null, 'Create New Bot')),
        h('div', { className: 'card', style: 'max-width:560px;' },
            h('div', { className: 'form-group' }, h('label', null, 'Name'), nameInp),
            h('div', { className: 'form-row' },
                h('div', { className: 'form-group' }, h('label', null, 'Race'), raceSel),
                h('div', { className: 'form-group' }, h('label', null, 'Sex'), sexSel)
            ),
            h('div', { className: 'form-row' },
                h('div', { className: 'form-group' }, h('label', null, 'Class ID'), classInp),
                h('div', { className: 'form-group' }, h('label', null, 'Level (1-85)'), lvlInp)
            ),
            h('div', { style: 'margin-top:8px;' }, submitBtn)
        )
    );
}

// ─── Scheduler ─────────────────────────────────────────────

async function renderScheduler(view) {
    view.innerHTML = '';
    view.append(h('div', { className: 'page-header' }, h('h2', null, 'Bot Scheduler')));
    const tableArea = h('div', null, loading());
    const formCard = h('div', { className: 'card', style: 'max-width:600px;margin-top:20px;' },
        h('div', { className: 'card-header' }, h('h3', null, 'Add New Schedule'))
    );
    view.append(tableArea, formCard);

    // Load bots for selector
    let allBots = [];
    try {
        const bd = await api('GET', '/api/autobots?page=1&pageSize=1000');
        allBots = bd.bots || [];
    } catch {}

    const botSel = h('select', null,
        h('option', { value: '' }, '— Select Bot —'),
        ...allBots.map(b => h('option', { value: b.objId }, `${b.name} (Lv.${b.level})`))
    );
    const spawnH = h('input', { type: 'number', min: '0', max: '23', value: '8', style: 'width:70px' });
    const spawnM = h('input', { type: 'number', min: '0', max: '59', value: '0', style: 'width:70px' });
    const despawnH = h('input', { type: 'number', min: '0', max: '23', value: '22', style: 'width:70px' });
    const despawnM = h('input', { type: 'number', min: '0', max: '59', value: '0', style: 'width:70px' });
    const daysCbs = DAYS.map((d, i) => {
        const cb = h('input', { type: 'checkbox', 'data-day': i }); cb.checked = true;
        return h('label', null, cb, d);
    });
    const enabledCb = h('input', { type: 'checkbox' }); enabledCb.checked = true;

    const createBtn = h('button', { className: 'btn btn-primary', onClick: async () => {
        if (!botSel.value) return toast('Select a bot', 'error');
        const daysOfWeek = [];
        daysCbs.forEach((lbl, i) => { if (lbl.querySelector('input').checked) daysOfWeek.push(i); });
        createBtn.disabled = true;
        try {
            await api('POST', '/api/autobots/schedule', {
                botId: +botSel.value,
                spawnHour: +spawnH.value, spawnMinute: +spawnM.value,
                despawnHour: +despawnH.value, despawnMinute: +despawnM.value,
                daysOfWeek, enabled: enabledCb.checked
            });
            toast('Schedule created');
            loadSchedules();
        } catch {}
        createBtn.disabled = false;
    }}, 'Create Schedule');

    formCard.append(
        h('div', { className: 'form-group' }, h('label', null, 'Bot'), botSel),
        h('div', { className: 'form-row' },
            h('div', { className: 'form-group' }, h('label', null, 'Spawn Time (H : M)'), h('div', { style: 'display:flex;gap:4px;align-items:center' }, spawnH, h('span', null, ':'), spawnM)),
            h('div', { className: 'form-group' }, h('label', null, 'Despawn Time (H : M)'), h('div', { style: 'display:flex;gap:4px;align-items:center' }, despawnH, h('span', null, ':'), despawnM))
        ),
        h('div', { className: 'form-group' }, h('label', null, 'Days of Week'), h('div', { className: 'day-checkboxes' }, ...daysCbs)),
        h('div', { className: 'form-group', style: 'display:flex;align-items:center;gap:8px' }, enabledCb, h('label', { style: 'margin:0' }, 'Enabled')),
        createBtn
    );

    async function loadSchedules() {
        tableArea.innerHTML = ''; tableArea.append(loading());
        try {
            const schedules = await api('GET', '/api/autobots/schedule');
            const list = Array.isArray(schedules) ? schedules : (schedules.schedules || []);
            tableArea.innerHTML = '';
            if (list.length === 0) {
                tableArea.append(h('p', { style: 'color:var(--text-muted);' }, 'No schedules configured.'));
                return;
            }
            const botMap = {};
            allBots.forEach(b => botMap[b.objId] = b.name);
            tableArea.append(h('div', { className: 'table-wrap' },
                h('table', null,
                    h('thead', null, h('tr', null,
                        h('th', null, 'Bot'), h('th', null, 'Spawn'), h('th', null, 'Despawn'), h('th', null, 'Days'), h('th', null, 'Status'), h('th', null, 'Actions')
                    )),
                    h('tbody', null, ...list.map(s => {
                        const days = (s.daysOfWeek || []).map(d => DAYS[d] || d).join(', ');
                        return h('tr', null,
                            h('td', null, botMap[s.botId] || `Bot #${s.botId}`),
                            h('td', null, `${pad2(s.spawnHour)}:${pad2(s.spawnMinute)}`),
                            h('td', null, `${pad2(s.despawnHour)}:${pad2(s.despawnMinute)}`),
                            h('td', { style: 'font-size:0.78rem;' }, days),
                            h('td', null, h('span', { className: `badge ${s.enabled ? 'badge-enabled' : 'badge-offline'}` }, s.enabled ? 'Enabled' : 'Disabled')),
                            h('td', null, h('button', { className: 'btn btn-sm btn-danger', onClick: async () => {
                                if (!await showConfirm('Delete Schedule', 'Remove this schedule?')) return;
                                try { await api('DELETE', `/api/autobots/schedule/${s.id}`); toast('Schedule deleted'); loadSchedules(); } catch {}
                            }}, 'Delete'))
                        );
                    }))
                )
            ));
        } catch { tableArea.innerHTML = '<p style="color:var(--text-muted);">Failed to load schedules.</p>'; }
    }
    loadSchedules();
}

// ─── Trade ─────────────────────────────────────────────────

let tradeSelectedZone = null;
let tradeEditingTrader = null;

async function renderTrade(view) {
    view.innerHTML = '';
    tradeSelectedZone = null;
    tradeEditingTrader = null;

    view.append(h('div', { className: 'page-header' }, h('h2', null, 'Trade Management')));

    // === Section A: Trade Zones ===
    const zonesCard = h('div', { className: 'card' },
        h('div', { className: 'card-header' },
            h('h3', null, 'Trade Zones'),
            h('button', { className: 'btn btn-sm btn-primary', onClick: () => toggleZoneForm() }, '+ Add Zone')
        )
    );
    const zoneFormWrap = h('div', { style: 'display:none;margin-bottom:16px;' });
    const zonesTableWrap = h('div', null, loading());
    zonesCard.append(zoneFormWrap, zonesTableWrap);

    // === Section B: Traders List ===
    const tradersCard = h('div', { className: 'card', style: 'display:none;' },
        h('div', { className: 'card-header' },
            h('h3', { id: 'traders-title' }, 'Traders'),
            h('button', { className: 'btn btn-sm btn-primary', onClick: () => toggleTraderForm() }, '+ Add Trader')
        )
    );
    const traderFormWrap = h('div', { style: 'display:none;margin-bottom:16px;' });
    const tradersTableWrap = h('div', null);
    tradersCard.append(traderFormWrap, tradersTableWrap);

    view.append(zonesCard, tradersCard);

    // ── Zone form toggle ──
    function toggleZoneForm() {
        if (zoneFormWrap.style.display === 'none') {
            zoneFormWrap.style.display = '';
            renderZoneForm();
        } else {
            zoneFormWrap.style.display = 'none';
        }
    }

    function renderZoneForm() {
        const nameInp = h('input', { type: 'text', placeholder: 'Zone name (e.g. Giran Market)' });
        const x1Inp = h('input', { type: 'number', placeholder: '82680' });
        const y1Inp = h('input', { type: 'number', placeholder: '149272' });
        const x2Inp = h('input', { type: 'number', placeholder: '83200' });
        const y2Inp = h('input', { type: 'number', placeholder: '149800' });
        const zInp = h('input', { type: 'number', placeholder: '-3472' });
        const maxInp = h('input', { type: 'number', value: '30', min: '1', placeholder: 'Max Traders' });

        const createBtn = h('button', { className: 'btn btn-primary', onClick: async () => {
            const name = nameInp.value.trim();
            if (!name) return toast('Zone name is required', 'error');
            if (!x1Inp.value || !y1Inp.value || !x2Inp.value || !y2Inp.value || !zInp.value)
                return toast('All coordinates are required', 'error');
            createBtn.disabled = true; createBtn.textContent = 'Creating...';
            try {
                await api('POST', '/api/trade/zones', {
                    name, x1: +x1Inp.value, y1: +y1Inp.value, x2: +x2Inp.value,
                    y2: +y2Inp.value, z: +zInp.value, maxTraders: +(maxInp.value || 30)
                });
                toast('Trade zone created');
                zoneFormWrap.style.display = 'none';
                loadZones();
            } catch {}
            createBtn.disabled = false; createBtn.textContent = 'Create Zone';
        }}, 'Create Zone');
        const cancelBtn = h('button', { className: 'btn btn-secondary', onClick: () => { zoneFormWrap.style.display = 'none'; } }, 'Cancel');

        zoneFormWrap.innerHTML = '';
        zoneFormWrap.append(
            h('div', { className: 'trade-zone-form' },
                h('div', { className: 'form-group' }, h('label', null, 'Zone Name'), nameInp),
                h('div', { className: 'coord-section' },
                    h('div', { className: 'coord-corner' },
                        h('span', { className: 'coord-corner-label' }, 'Corner 1 (top-left)'),
                        h('div', { className: 'coord-pair' },
                            h('div', { className: 'form-group' }, h('label', null, 'X1'), x1Inp),
                            h('div', { className: 'form-group' }, h('label', null, 'Y1'), y1Inp)
                        )
                    ),
                    h('div', { className: 'coord-corner' },
                        h('span', { className: 'coord-corner-label' }, 'Corner 2 (bottom-right)'),
                        h('div', { className: 'coord-pair' },
                            h('div', { className: 'form-group' }, h('label', null, 'X2'), x2Inp),
                            h('div', { className: 'form-group' }, h('label', null, 'Y2'), y2Inp)
                        )
                    ),
                    h('div', { className: 'coord-corner coord-z' },
                        h('span', { className: 'coord-corner-label' }, 'Altitude'),
                        h('div', { className: 'coord-pair' },
                            h('div', { className: 'form-group' }, h('label', null, 'Z'), zInp)
                        )
                    )
                ),
                h('div', { className: 'form-group' }, h('label', null, 'Max Traders'), maxInp),
                h('div', { className: 'btn-group', style: 'margin-top:8px;' }, createBtn, cancelBtn)
            )
        );
    }

    // ── Load zones ──
    async function loadZones() {
        zonesTableWrap.innerHTML = ''; zonesTableWrap.append(loading());
        try {
            const data = await api('GET', '/api/trade/zones');
            const zones = data.zones || [];
            zonesTableWrap.innerHTML = '';
            if (zones.length === 0) {
                zonesTableWrap.append(h('p', { style: 'color:var(--text-muted);padding:12px 0;' }, 'No trade zones configured.'));
                return;
            }
            // Also get traders for counts
            let allTraders = [];
            try {
                const td = await api('GET', '/api/trade/traders');
                allTraders = td.traders || [];
            } catch {}

            const tbody = h('tbody', null, ...zones.map(z => {
                const zoneTraders = allTraders.filter(t => t.zoneId === z.id);
                const activeCount = zoneTraders.filter(t => t.isActive).length;
                const isSelected = tradeSelectedZone && tradeSelectedZone.id === z.id;
                const row = h('tr', {
                    className: isSelected ? 'zone-row selected' : 'zone-row',
                    onClick: () => selectZone(z)
                },
                    h('td', null, h('span', { className: 'zone-name-link' }, z.name)),
                    h('td', { className: 'coord-cell' }, `${z.x1}, ${z.y1} → ${z.x2}, ${z.y2}`),
                    h('td', null, String(z.z)),
                    h('td', null, String(z.maxTraders)),
                    h('td', null,
                        h('span', { className: `badge ${activeCount > 0 ? 'badge-online' : 'badge-offline'}` },
                            `${activeCount} / ${zoneTraders.length}`
                        )
                    ),
                    h('td', null,
                        h('div', { className: 'btn-group' },
                            h('button', { className: 'btn btn-sm btn-success', onClick: async (e) => {
                                e.stopPropagation();
                                try { await api('POST', `/api/trade/zones/${z.id}/activate-all`); toast('All traders activated'); loadZones(); if (tradeSelectedZone && tradeSelectedZone.id === z.id) loadTraders(z); } catch {}
                            }}, 'Activate All'),
                            h('button', { className: 'btn btn-sm btn-warning', onClick: async (e) => {
                                e.stopPropagation();
                                try { await api('POST', `/api/trade/zones/${z.id}/deactivate-all`); toast('All traders deactivated'); loadZones(); if (tradeSelectedZone && tradeSelectedZone.id === z.id) loadTraders(z); } catch {}
                            }}, 'Deactivate All'),
                            h('button', { className: 'btn btn-sm btn-danger', onClick: async (e) => {
                                e.stopPropagation();
                                if (!await showConfirm('Delete Zone', `Delete zone "${z.name}" and all its traders?`)) return;
                                try {
                                    await api('DELETE', `/api/trade/zones/${z.id}`);
                                    toast('Zone deleted');
                                    if (tradeSelectedZone && tradeSelectedZone.id === z.id) {
                                        tradeSelectedZone = null;
                                        tradersCard.style.display = 'none';
                                    }
                                    loadZones();
                                } catch {}
                            }}, 'Delete')
                        )
                    )
                );
                return row;
            }));

            zonesTableWrap.append(h('div', { className: 'table-wrap' },
                h('table', null,
                    h('thead', null, h('tr', null,
                        h('th', null, 'Name'), h('th', null, 'Coordinates'), h('th', null, 'Z'),
                        h('th', null, 'Max'), h('th', null, 'Active / Total'), h('th', null, 'Actions')
                    )),
                    tbody
                )
            ));
        } catch {
            zonesTableWrap.innerHTML = '<p style="color:var(--text-muted);padding:12px;">Failed to load trade zones.</p>';
        }
    }

    // ── Select zone ──
    function selectZone(zone) {
        tradeSelectedZone = zone;
        tradersCard.style.display = '';
        const title = tradersCard.querySelector('#traders-title');
        if (title) title.textContent = `Traders — ${zone.name}`;
        loadTraders(zone);
        // re-render zones to highlight
        loadZones();
    }

    // ── Trader form toggle ──
    let allBots = null;
    async function ensureBots() {
        if (allBots) return allBots;
        try {
            const bd = await api('GET', '/api/autobots?page=1&pageSize=1000');
            allBots = bd.bots || [];
        } catch { allBots = []; }
        return allBots;
    }

    function toggleTraderForm(editTrader) {
        tradeEditingTrader = editTrader || null;
        if (traderFormWrap.style.display === 'none' || editTrader) {
            traderFormWrap.style.display = '';
            renderTraderForm();
        } else {
            traderFormWrap.style.display = 'none';
        }
    }

    async function renderTraderForm() {
        traderFormWrap.innerHTML = '';
        traderFormWrap.append(loading());
        const bots = await ensureBots();
        const ed = tradeEditingTrader;

        const botSel = h('select', null,
            h('option', { value: '' }, '— Select Bot —'),
            ...bots.map(b => {
                const opt = h('option', { value: b.objId }, `${b.name} (Lv.${b.level})`);
                if (ed && ed.botId === b.objId) opt.selected = true;
                return opt;
            })
        );

        const sellRadio = h('input', { type: 'radio', name: 'tradeType', value: 'sell' });
        const buyRadio = h('input', { type: 'radio', name: 'tradeType', value: 'buy' });
        if (ed && ed.tradeType === 'buy') buyRadio.checked = true; else sellRadio.checked = true;

        const storeNameInp = h('input', { type: 'text', placeholder: 'Store title visible to players', value: ed ? ed.storeName || '' : '' });

        // Dynamic items list
        const itemsContainer = h('div', { className: 'trade-items-list' });
        let itemRows = [];

        function addItemRow(itemId, count, price) {
            const idInp = h('input', { type: 'number', placeholder: 'Item ID', value: itemId || '', style: 'width:100px' });
            const countInp = h('input', { type: 'number', placeholder: 'Count', value: count || '', min: '1', style: 'width:90px' });
            const priceInp = h('input', { type: 'number', placeholder: 'Price', value: price || '', min: '0', style: 'width:110px' });
            const removeBtn = h('button', { className: 'btn btn-sm btn-danger', onClick: () => {
                const idx = itemRows.indexOf(row);
                if (idx >= 0) { itemRows.splice(idx, 1); row.remove(); }
            }}, '✕');
            const row = h('div', { className: 'trade-item-row' }, idInp, countInp, priceInp, removeBtn);
            row._inputs = { idInp, countInp, priceInp };
            itemRows.push(row);
            itemsContainer.append(row);
        }

        if (ed && ed.items && ed.items.length > 0) {
            ed.items.forEach(it => addItemRow(it.itemId, it.count, it.price));
        } else {
            addItemRow('', '', '');
        }

        const addItemBtn = h('button', { className: 'btn btn-sm btn-secondary', onClick: () => addItemRow('', '', '') }, '+ Add Item');

        const saveBtn = h('button', { className: 'btn btn-primary', onClick: async () => {
            if (!botSel.value) return toast('Select a bot', 'error');
            const storeName = storeNameInp.value.trim();
            if (!storeName) return toast('Store name is required', 'error');
            const tradeType = buyRadio.checked ? 'buy' : 'sell';
            const items = itemRows.map(r => ({
                itemId: +r._inputs.idInp.value,
                count: +r._inputs.countInp.value,
                price: +r._inputs.priceInp.value
            })).filter(it => it.itemId > 0 && it.count > 0);
            if (items.length === 0) return toast('Add at least one item', 'error');

            saveBtn.disabled = true; saveBtn.textContent = 'Saving...';
            try {
                if (ed) {
                    await api('PUT', `/api/trade/traders/${ed.id}`, {
                        botId: +botSel.value, zoneId: tradeSelectedZone.id,
                        tradeType, storeName, items
                    });
                    toast('Trader updated');
                } else {
                    await api('POST', '/api/trade/traders', {
                        botId: +botSel.value, zoneId: tradeSelectedZone.id,
                        tradeType, storeName, items
                    });
                    toast('Trader created');
                }
                traderFormWrap.style.display = 'none';
                tradeEditingTrader = null;
                loadTraders(tradeSelectedZone);
                loadZones();
            } catch {}
            saveBtn.disabled = false; saveBtn.textContent = ed ? 'Save Changes' : 'Create Trader';
        }}, ed ? 'Save Changes' : 'Create Trader');
        const cancelBtn = h('button', { className: 'btn btn-secondary', onClick: () => { traderFormWrap.style.display = 'none'; tradeEditingTrader = null; } }, 'Cancel');

        traderFormWrap.innerHTML = '';
        traderFormWrap.append(
            h('div', { className: 'trade-trader-form' },
                h('h4', { style: 'margin-bottom:12px;color:var(--accent);' }, ed ? 'Edit Trader' : 'New Trader'),
                h('div', { className: 'form-row' },
                    h('div', { className: 'form-group' }, h('label', null, 'Bot'), botSel),
                    h('div', { className: 'form-group' }, h('label', null, 'Store Name'), storeNameInp)
                ),
                h('div', { className: 'form-group' },
                    h('label', null, 'Trade Type'),
                    h('div', { className: 'trade-type-radios' },
                        h('label', { className: 'trade-type-option' }, sellRadio, h('span', { className: 'badge badge-sell' }, 'Sell')),
                        h('label', { className: 'trade-type-option' }, buyRadio, h('span', { className: 'badge badge-buy' }, 'Buy'))
                    )
                ),
                h('div', { className: 'form-group' },
                    h('label', null, 'Items'),
                    h('div', { className: 'trade-items-header' },
                        h('span', null, 'Item ID'), h('span', null, 'Count'), h('span', null, 'Price (Adena)'), h('span')
                    ),
                    itemsContainer,
                    h('div', { style: 'margin-top:6px;' }, addItemBtn)
                ),
                h('p', { className: 'trade-note' }, 'Bots automatically receive 999,999 Coin of Luck and 9,999,999,999 Adena'),
                h('div', { className: 'btn-group', style: 'margin-top:12px;' }, saveBtn, cancelBtn)
            )
        );
    }

    // ── Load traders for zone ──
    async function loadTraders(zone) {
        tradersTableWrap.innerHTML = ''; tradersTableWrap.append(loading());
        try {
            const data = await api('GET', `/api/trade/traders?zoneId=${zone.id}`);
            const traders = data.traders || [];
            tradersTableWrap.innerHTML = '';
            if (traders.length === 0) {
                tradersTableWrap.append(h('p', { style: 'color:var(--text-muted);padding:12px 0;' }, 'No traders in this zone yet.'));
                return;
            }
            const tbody = h('tbody', null, ...traders.map(t => {
                const itemsCount = (t.items || []).length;
                const itemsTooltip = (t.items || []).map(it => `ID:${it.itemId} x${it.count} @${it.price}`).join('\n');
                return h('tr', null,
                    h('td', null, t.botName || `Bot #${t.botId}`),
                    h('td', null, String(t.slotIndex ?? '—')),
                    h('td', null, h('span', { className: `badge ${t.tradeType === 'sell' ? 'badge-sell' : 'badge-buy'}` }, t.tradeType === 'sell' ? 'Sell' : 'Buy')),
                    h('td', null, t.storeName || '—'),
                    h('td', null, h('span', { className: 'items-count', title: itemsTooltip }, `${itemsCount} item${itemsCount !== 1 ? 's' : ''}`)),
                    h('td', null, h('span', { className: `badge ${t.isActive ? 'badge-online' : 'badge-offline'}` }, t.isActive ? 'Active' : 'Inactive')),
                    h('td', null,
                        h('div', { className: 'btn-group' },
                            t.isActive
                                ? h('button', { className: 'btn btn-sm btn-warning', onClick: async () => {
                                    try { await api('POST', `/api/trade/traders/${t.id}/deactivate`); toast(`${t.botName || 'Trader'} deactivated`); loadTraders(zone); loadZones(); } catch {}
                                }}, 'Deactivate')
                                : h('button', { className: 'btn btn-sm btn-success', onClick: async () => {
                                    try { await api('POST', `/api/trade/traders/${t.id}/activate`); toast(`${t.botName || 'Trader'} activated`); loadTraders(zone); loadZones(); } catch {}
                                }}, 'Activate'),
                            h('button', { className: 'btn btn-sm btn-secondary', onClick: () => toggleTraderForm(t) }, 'Edit'),
                            h('button', { className: 'btn btn-sm btn-danger', onClick: async () => {
                                if (!await showConfirm('Delete Trader', `Delete trader "${t.botName || t.id}"?`)) return;
                                try { await api('DELETE', `/api/trade/traders/${t.id}`); toast('Trader deleted'); loadTraders(zone); loadZones(); } catch {}
                            }}, 'Del')
                        )
                    )
                );
            }));

            tradersTableWrap.append(h('div', { className: 'table-wrap' },
                h('table', null,
                    h('thead', null, h('tr', null,
                        h('th', null, 'Bot Name'), h('th', null, 'Slot'), h('th', null, 'Type'),
                        h('th', null, 'Store Name'), h('th', null, 'Items'), h('th', null, 'Status'), h('th', null, 'Actions')
                    )),
                    tbody
                )
            ));
        } catch {
            tradersTableWrap.innerHTML = '<p style="color:var(--text-muted);padding:12px;">Failed to load traders.</p>';
        }
    }

    // Initial load
    loadZones();
}

// ─── Starter Pack ──────────────────────────────────────────

async function renderStarterPack(view) {
    view.innerHTML = '';
    view.append(
        h('div', { className: 'page-header' }, h('h2', null, '\u2694 Starter Pack')),
        loading()
    );

    let statusData = { total: 0, farming: 0, walking: 0, inTown: 0, maxBots: 250, enabled: false };

    try {
        statusData = await api('GET', '/api/starterpack/status');
    } catch {}

    view.innerHTML = '';

    const hasActiveBots = statusData.total > 0;

    // ── Controls Card ──
    const countInp = h('input', {
        type: 'number', value: '50', min: '1', max: String(statusData.maxBots || 250),
        style: 'width:140px;'
    });

    const startSpinner = h('span', { className: 'spinner', style: 'width:14px;height:14px;display:none;margin-right:6px;' });
    const startBtn = h('button', {
        className: 'btn btn-success btn-sp-start',
        disabled: hasActiveBots || undefined,
        onClick: async () => {
            const count = +countInp.value;
            if (!count || count < 1) return toast('Enter a valid count', 'error');
            startBtn.disabled = true;
            startSpinner.style.display = '';
            try {
                await api('POST', '/api/starterpack/start', { count });
                toast(`Spawning ${count} starter bots...`);
                refreshStatus();
            } catch {}
            startSpinner.style.display = 'none';
            startBtn.disabled = false;
        }
    }, startSpinner, '\u25B6 Start Spawning');

    const stopBtn = h('button', {
        className: 'btn btn-danger',
        disabled: !hasActiveBots || undefined,
        onClick: async () => {
            if (!await showConfirm('Stop All', 'Stop and despawn all starter pack bots?')) return;
            stopBtn.disabled = true;
            try {
                await api('POST', '/api/starterpack/stop');
                toast('All starter bots stopped');
                refreshStatus();
            } catch {}
            stopBtn.disabled = false;
        }
    }, '\u23F9 Stop All');

    const controlsCard = h('div', { className: 'card' },
        h('div', { className: 'card-header' }, h('h3', null, 'Spawn Controls')),
        h('div', { className: 'sp-controls' },
            h('div', { className: 'form-group', style: 'margin-bottom:0;' },
                h('label', null, 'Spawn Count'),
                countInp
            ),
            h('div', { className: 'btn-group', style: 'align-items:flex-end;' }, startBtn, stopBtn)
        )
    );

    // ── Status Cards ──
    const makeSpCard = (icon, value, label, cls) => {
        return h('div', { className: `sp-status-card ${cls}` },
            h('div', { className: 'sp-card-icon' }, icon),
            h('div', { className: 'sp-card-value' }, String(value)),
            h('div', { className: 'sp-card-label' }, label)
        );
    };

    const cardTotal = makeSpCard('\u2694', statusData.total, 'Total', 'sp-accent');
    const cardFarming = makeSpCard('\uD83D\uDDE1', statusData.farming, 'Farming', 'sp-orange');
    const cardWalking = makeSpCard('\uD83D\uDEB6', statusData.walking, 'Walking to Town', 'sp-blue');
    const cardTown = makeSpCard('\uD83C\uDFE0', statusData.inTown, 'In Town', 'sp-green');

    const statusGrid = h('div', { className: 'sp-status-grid' },
        cardTotal, cardFarming, cardWalking, cardTown
    );

    // ── Progress Bar ──
    const progressPct = statusData.total > 0 ? Math.round((statusData.inTown / statusData.total) * 100) : 0;
    const progressFill = h('div', { className: 'sp-progress-fill', style: `width:${progressPct}%` });
    const progressLabel = h('span', { className: 'sp-progress-label' }, `${progressPct}%`);
    const progressBar = h('div', { className: 'sp-progress-wrap' },
        h('div', { className: 'sp-progress-header' },
            h('span', null, 'Progress (In Town / Total)'),
            progressLabel
        ),
        h('div', { className: 'sp-progress-bar' }, progressFill)
    );

    // ── Info line ──
    const infoLine = h('div', { className: 'sp-info-line' },
        h('span', null, `Max bots: ${statusData.maxBots}`),
        h('span', null,
            `System: ${statusData.enabled ? 'Enabled' : 'Disabled'} `,
            h('span', { className: statusData.enabled ? 'sp-enabled' : 'sp-disabled' }, statusData.enabled ? '\u2713' : '\u2717')
        )
    );

    const statusCard = h('div', { className: 'card' },
        h('div', { className: 'card-header' },
            h('h3', null, 'Status'),
            h('span', { style: 'font-size:0.72rem;color:var(--text-muted);text-transform:uppercase;letter-spacing:1px;' }, 'Auto-refresh 5s')
        ),
        statusGrid,
        progressBar,
        infoLine
    );

    view.append(
        h('div', { className: 'page-header' }, h('h2', null, '\u2694 Starter Pack')),
        controlsCard,
        statusCard
    );

    // ── Auto-refresh ──
    async function refreshStatus() {
        try {
            const s = await api('GET', '/api/starterpack/status');
            // Update card values
            cardTotal.querySelector('.sp-card-value').textContent = s.total;
            cardFarming.querySelector('.sp-card-value').textContent = s.farming;
            cardWalking.querySelector('.sp-card-value').textContent = s.walking;
            cardTown.querySelector('.sp-card-value').textContent = s.inTown;

            // Update progress
            const pct = s.total > 0 ? Math.round((s.inTown / s.total) * 100) : 0;
            progressFill.style.width = pct + '%';
            progressLabel.textContent = pct + '%';

            // Update info
            infoLine.innerHTML = '';
            infoLine.append(
                h('span', null, `Max bots: ${s.maxBots}`),
                h('span', null,
                    `System: ${s.enabled ? 'Enabled' : 'Disabled'} `,
                    h('span', { className: s.enabled ? 'sp-enabled' : 'sp-disabled' }, s.enabled ? '\u2713' : '\u2717')
                )
            );

            // Update button states
            const active = s.total > 0;
            startBtn.disabled = active;
            stopBtn.disabled = !active;
        } catch {}
    }

    refreshTimer = setInterval(() => {
        if (currentRoute !== 'starterpack') return;
        refreshStatus();
    }, 5000);
}

// ─── Settings ──────────────────────────────────────────────

function renderSettings(view) {
    view.innerHTML = '';
    const keyInp = h('input', { type: 'password', value: getApiKey(), placeholder: 'API Key' });
    const saveBtn = h('button', { className: 'btn btn-primary', onClick: () => {
        const key = keyInp.value.trim();
        if (!key) return toast('Key cannot be empty', 'error');
        localStorage.setItem('l2_api_key', key);
        toast('API key updated');
        checkConnection();
    }}, 'Save Key');
    const clearBtn = h('button', { className: 'btn btn-danger', onClick: async () => {
        if (!await showConfirm('Clear Data', 'Remove API key from local storage?')) return;
        localStorage.removeItem('l2_api_key');
        toast('API key cleared');
        keyInp.value = '';
        checkConnection();
    }}, 'Clear Key');

    view.append(
        h('div', { className: 'page-header' }, h('h2', null, 'Settings')),
        h('div', { className: 'card settings-section' },
            h('div', { className: 'card-header' }, h('h3', null, 'API Configuration')),
            h('div', { className: 'form-group' }, h('label', null, 'API Key'), keyInp),
            h('div', { className: 'btn-group' }, saveBtn, clearBtn)
        ),
        h('div', { className: 'card settings-section', style: 'margin-top:16px;' },
            h('div', { className: 'card-header' }, h('h3', null, 'Connection Test')),
            h('button', { className: 'btn btn-secondary', onClick: async () => {
                try {
                    const s = await api('GET', '/api/server/status');
                    toast(`Connected! ${s.onlineBots} bots online, uptime ${formatUptime(s.uptimeSeconds)}`);
                } catch { toast('Connection failed', 'error'); }
            }}, 'Test Connection')
        )
    );
}

// ─── Init ──────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
    if (!getApiKey()) showApiKeyModal();
    else checkConnection();
    route();
});
