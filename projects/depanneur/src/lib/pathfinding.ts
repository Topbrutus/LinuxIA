/**
 * Pathfinding A* grid-based pour la carte du magasin.
 *
 * - Grille GRID_SIZE×GRID_SIZE (coordonnées entières)
 * - 4 directions (pas de diagonal)
 * - Heuristique Manhattan
 * - Lissage de chemin par visibilité directe (Bresenham)
 * - Entrée/sortie en pourcentages (0–100)
 */
import { GRID_SIZE, isBlocked } from "@/data/storeNav";

/* ── Helpers grille ─────────────────────────────────────────────────── */

const CELL = 100 / GRID_SIZE;

function pctToGrid(p: number): number {
  return Math.min(GRID_SIZE - 1, Math.max(0, Math.floor(p / CELL)));
}

function gridToPct(g: number): number {
  return (g + 0.5) * CELL;
}

function isBlockedCell(gx: number, gy: number): boolean {
  return isBlocked(gridToPct(gx), gridToPct(gy));
}

/* ── Snap au premier voisin libre (spirale BFS) ────────────────────── */
function snapFree(gx: number, gy: number): { x: number; y: number } {
  if (!isBlockedCell(gx, gy)) return { x: gx, y: gy };
  for (let r = 1; r <= 8; r++) {
    for (let dx = -r; dx <= r; dx++) {
      for (let dy = -r; dy <= r; dy++) {
        if (Math.abs(dx) < r && Math.abs(dy) < r) continue;
        const nx = gx + dx;
        const ny = gy + dy;
        if (nx >= 0 && ny >= 0 && nx < GRID_SIZE && ny < GRID_SIZE && !isBlockedCell(nx, ny)) {
          return { x: nx, y: ny };
        }
      }
    }
  }
  return { x: gx, y: gy };
}

/* ── Visibilité directe (Bresenham) ────────────────────────────────── */
function hasLOS(ax: number, ay: number, bx: number, by: number): boolean {
  let x = ax;
  let y = ay;
  const dx = Math.abs(bx - ax);
  const dy = Math.abs(by - ay);
  const sx = bx > ax ? 1 : -1;
  const sy = by > ay ? 1 : -1;
  let err = dx - dy;

  while (x !== bx || y !== by) {
    if (isBlockedCell(x, y)) return false;
    const e2 = 2 * err;
    if (e2 > -dy) { err -= dy; x += sx; }
    if (e2 <  dx) { err += dx; y += sy; }
  }
  return !isBlockedCell(bx, by);
}

/* ── Lissage du chemin (supprime waypoints intermédiaires visibles) ── */
export interface Waypoint {
  x: number;
  y: number;
}

function smoothPath(path: Waypoint[]): Waypoint[] {
  if (path.length <= 2) return path;
  const out: Waypoint[] = [path[0]];
  let i = 0;
  while (i < path.length - 1) {
    let j = path.length - 1;
    while (j > i + 1) {
      if (hasLOS(
        pctToGrid(path[i].x), pctToGrid(path[i].y),
        pctToGrid(path[j].x), pctToGrid(path[j].y),
      )) break;
      j--;
    }
    i = j;
    out.push(path[i]);
  }
  return out;
}

/* ── A* ─────────────────────────────────────────────────────────────── */

interface Node {
  x:      number;
  y:      number;
  g:      number;
  h:      number;
  f:      number;
  parent: Node | null;
}

function manhattan(ax: number, ay: number, bx: number, by: number): number {
  return Math.abs(ax - bx) + Math.abs(ay - by);
}

const DIRS: readonly [number, number][] = [[0, 1], [0, -1], [1, 0], [-1, 0]];

/**
 * Retourne un chemin de (fromXPct,fromYPct) vers (toXPct,toYPct) en %.
 * N'inclut PAS le point de départ. Fallback vers destination directe si
 * aucun chemin n'existe.
 */
export function findPath(
  fromXPct: number,
  fromYPct: number,
  toXPct:   number,
  toYPct:   number,
): Waypoint[] {
  const start = snapFree(pctToGrid(fromXPct), pctToGrid(fromYPct));
  const goal  = snapFree(pctToGrid(toXPct),   pctToGrid(toYPct));

  if (start.x === goal.x && start.y === goal.y) {
    return [{ x: toXPct, y: toYPct }];
  }

  // Ligne droite libre : pas besoin de A*
  if (hasLOS(start.x, start.y, goal.x, goal.y)) {
    return [{ x: toXPct, y: toYPct }];
  }

  const open:    Node[]               = [];
  const closed:  Set<string>          = new Set();
  const gScores: Map<string, number>  = new Map();

  const h0 = manhattan(start.x, start.y, goal.x, goal.y);
  open.push({ x: start.x, y: start.y, g: 0, h: h0, f: h0, parent: null });
  gScores.set(`${start.x},${start.y}`, 0);

  while (open.length > 0) {
    // Nœud avec f minimal (scan linéaire OK pour 50×50 = 2 500 nœuds max)
    let bi = 0;
    for (let i = 1; i < open.length; i++) {
      if (open[i].f < open[bi].f) bi = i;
    }
    const cur = open[bi];
    open.splice(bi, 1);

    const ck = `${cur.x},${cur.y}`;
    if (closed.has(ck)) continue;
    closed.add(ck);

    if (cur.x === goal.x && cur.y === goal.y) {
      const raw: Waypoint[] = [];
      let node: Node | null = cur;
      while (node !== null) {
        raw.unshift({ x: gridToPct(node.x), y: gridToPct(node.y) });
        node = node.parent;
      }
      raw.shift(); // retire le point de départ
      return smoothPath(raw);
    }

    for (const [ddx, ddy] of DIRS) {
      const nx = cur.x + ddx;
      const ny = cur.y + ddy;
      if (nx < 0 || ny < 0 || nx >= GRID_SIZE || ny >= GRID_SIZE) continue;
      const nk = `${nx},${ny}`;
      if (closed.has(nk))        continue;
      if (isBlockedCell(nx, ny)) continue;

      const g  = cur.g + 1;
      const kg = gScores.get(nk) ?? Infinity;
      if (g >= kg) continue;

      gScores.set(nk, g);
      const h = manhattan(nx, ny, goal.x, goal.y);
      open.push({ x: nx, y: ny, g, h, f: g + h, parent: cur });
    }
  }

  // Aucun chemin — destination directe
  return [{ x: toXPct, y: toYPct }];
}
