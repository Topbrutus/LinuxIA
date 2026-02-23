const canvas = document.getElementById("fx");
const ctx = canvas.getContext("2d", { alpha: true });
let W = 0, H = 0;

function resize() {
  const r = canvas.getBoundingClientRect();
  W = canvas.width = Math.floor(r.width * devicePixelRatio);
  H = canvas.height = Math.floor(r.height * devicePixelRatio);
}
window.addEventListener("resize", resize);
resize();

let reduced = false;
window.addEventListener("keydown", (e) => {
  if (e.key.toLowerCase() === "m") reduced = !reduced;
});

const mouse = { x: 0, y: 0, active: false };
window.addEventListener("mousemove", (e) => {
  const r = canvas.getBoundingClientRect();
  mouse.x = (e.clientX - r.left) * devicePixelRatio;
  mouse.y = (e.clientY - r.top) * devicePixelRatio;
  mouse.active = true;
});

function rand(a, b) { return a + Math.random() * (b - a); }
function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }

const colors = ["#FFD700", "#00C8FF", "#73BA25", "#FF8A00", "#6A2CFF"];
let particles = [];
function initParticles(n) {
  particles = Array.from({ length: n }, () => ({
    x: rand(0, W), y: rand(0, H),
    vx: rand(-0.35, 0.35), vy: rand(-0.25, 0.25),
    r: rand(0.8, 2.2) * devicePixelRatio,
    c: pick(colors),
    a: rand(0.25, 0.85),
  }));
}
initParticles(140);

function step() {
  ctx.clearRect(0, 0, W, H);
  const N = reduced ? Math.floor(particles.length * 0.35) : particles.length;
  for (let i = 0; i < N; i++) {
    const p = particles[i];
    if (mouse.active) {
      const dx = mouse.x - p.x;
      const dy = mouse.y - p.y;
      const d2 = dx*dx + dy*dy + 1;
      const f = 14 / d2;
      p.vx += dx * f * 0.03;
      p.vy += dy * f * 0.03;
    }
    p.vx *= 0.985; p.vy *= 0.985;
    p.x += p.vx * devicePixelRatio;
    p.y += p.vy * devicePixelRatio;
    if (p.x < -20) p.x = W + 20;
    if (p.x > W + 20) p.x = -20;
    if (p.y < -20) p.y = H + 20;
    if (p.y > H + 20) p.y = -20;
    ctx.globalAlpha = p.a;
    ctx.fillStyle = p.c;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.globalAlpha = 0.10;
  ctx.strokeStyle = "#00C8FF";
  ctx.lineWidth = 1 * devicePixelRatio;
  for (let i = 0; i < N; i += 6) {
    const a = particles[i];
    const b = particles[(i + 7) % N];
    const dx = a.x - b.x, dy = a.y - b.y;
    const d = Math.sqrt(dx*dx + dy*dy);
    if (d < 220 * devicePixelRatio) {
      ctx.globalAlpha = 0.08;
      ctx.beginPath();
      ctx.moveTo(a.x, a.y);
      ctx.lineTo(b.x, b.y);
      ctx.stroke();
    }
  }
  requestAnimationFrame(step);
}
step();

const stack = document.getElementById("photoStack");
if (stack) {
  const imgs = [...stack.querySelectorAll("img")];
  let z = 10;
  function randomize() {
    imgs.forEach((img, i) => {
      img.style.setProperty("--rot", `${(Math.random()*10 - 5).toFixed(2)}deg`);
      img.style.left = `${50 + (Math.random()*6 - 3)}%`;
      img.style.top = `${50 + (Math.random()*6 - 3)}%`;
      img.style.zIndex = String(z + i);
    });
    z += imgs.length;
  }
  randomize();
  imgs.forEach((img) => {
    let dragging = false;
    let ox = 0, oy = 0;
    img.addEventListener("mousedown", (e) => {
      dragging = true;
      img.style.zIndex = String(++z);
      const r = img.getBoundingClientRect();
      ox = e.clientX - r.left;
      oy = e.clientY - r.top;
      e.preventDefault();
    });
    window.addEventListener("mousemove", (e) => {
      if (!dragging) return;
      const cr = stack.getBoundingClientRect();
      const x = e.clientX - cr.left - ox;
      const y = e.clientY - cr.top - oy;
      img.style.left = `${(x / cr.width) * 100}%`;
      img.style.top = `${(y / cr.height) * 100}%`;
    });
    window.addEventListener("mouseup", () => dragging = false);
  });
  stack.addEventListener("dblclick", randomize);
}
