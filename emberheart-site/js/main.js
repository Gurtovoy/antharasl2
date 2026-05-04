// Preloader
window.addEventListener('load', () => {
    setTimeout(() => {
        document.getElementById('preloader').classList.add('done');
    }, 1200);
});

// Ember particles
const embersContainer = document.getElementById('embers');
if (embersContainer) {
    for (let i = 0; i < 30; i++) {
        const ember = document.createElement('div');
        ember.className = 'ember';
        ember.style.left = Math.random() * 100 + '%';
        ember.style.bottom = '-10px';
        ember.style.animationDuration = (Math.random() * 8 + 6) + 's';
        ember.style.animationDelay = Math.random() * 10 + 's';
        ember.style.width = (Math.random() * 3 + 2) + 'px';
        ember.style.height = ember.style.width;
        embersContainer.appendChild(ember);
    }
}

// Scroll reveal
const revealElements = document.querySelectorAll('.reveal');
const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
}, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

revealElements.forEach(el => revealObserver.observe(el));

// Active nav link on scroll
const sections = document.querySelectorAll('section[id]');
const navLinks = document.querySelectorAll('.sidenav-link');

window.addEventListener('scroll', () => {
    let current = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        if (scrollY >= sectionTop - 300) {
            current = section.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === '#' + current) {
            link.classList.add('active');
        }
    });
});

// Mobile menu
const mobileMenuBtn = document.getElementById('mobileMenuBtn');
const sidenav = document.getElementById('sidenav');
if (mobileMenuBtn && sidenav) {
    mobileMenuBtn.addEventListener('click', () => {
        sidenav.classList.toggle('open');
    });
}

// Close mobile menu on link click
document.querySelectorAll('.sidenav-link').forEach(link => {
    link.addEventListener('click', () => {
        if (sidenav) sidenav.classList.remove('open');
    });
});

// Simulate live online counter
function updateOnline() {
    const baseOnline = 2847;
    const variance = Math.floor(Math.random() * 40) - 20;
    const newOnline = baseOnline + variance;
    const statOnline = document.getElementById('statOnline');
    if (statOnline) statOnline.textContent = newOnline.toLocaleString('ru-RU');

    const server1Base = 1542;
    const server1Var = Math.floor(Math.random() * 20) - 10;
    const server1Online = document.getElementById('server1Online');
    if (server1Online) server1Online.textContent = (server1Base + server1Var).toLocaleString('ru-RU');
}
setInterval(updateOnline, 5000);
