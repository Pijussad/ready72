import fs from "fs";
import { feature } from "topojson-client";
import { geoTransverseMercator, geoPath } from "d3-geo";

const topo = JSON.parse(fs.readFileSync("node_modules/world-atlas/countries-10m.json"));
const countries = feature(topo, topo.objects.countries).features;
const lt = countries.find((f) => String(f.id) === "440");
const adm2 = JSON.parse(fs.readFileSync("adm2.geojson"));
const adm1 = JSON.parse(fs.readFileSync("adm1.geojson"));

const rewind = (fc) => ({...fc, features: fc.features.map((f) => ({...f, geometry: f.geometry.type === "Polygon" ? {...f.geometry, coordinates: f.geometry.coordinates.map((r) => r.slice().reverse())} : {...f.geometry, coordinates: f.geometry.coordinates.map((p) => p.map((r) => r.slice().reverse()))}}))});
const adm2r = rewind(adm2), adm1r = rewind(adm1);
const W = 600, H = 520;
const proj = geoTransverseMercator().rotate([-24, 0]).fitExtent([[20, 20], [W - 20, H - 20]], lt);
const path = geoPath(proj);

const cities = [
  ["Vilnius", 25.2797, 54.6872], ["Kaunas", 23.9036, 54.8985], ["Klaipėda", 21.1443, 55.7033],
  ["Šiauliai", 23.3137, 55.9349], ["Panevėžys", 24.3575, 55.7348], ["Alytus", 24.0459, 54.3963],
  ["Marijampolė", 23.3541, 54.5599], ["Utena", 25.5992, 55.4978],
];

const real = path(lt);
fs.writeFileSync("real.d", real);
const mun = adm2r.features.map((f) => `<path d="${path(f)}" fill="#fff" stroke="#999" stroke-width="0.6"/>`).join("");
const cty = adm1r.features.map((f) => `<path d="${path(f)}" fill="none" stroke="#111" stroke-width="1.2"/>`).join("");
const dots = cities.map(([n, lo, la]) => { const [x, y] = proj([lo, la]); return `<circle cx="${x}" cy="${y}" r="4" fill="#d9333f"/><text x="${x+8}" y="${y+4}" font-size="13" font-family="Helvetica">${n}</text>`; }).join("");

const mine = "M 95 152 L 120 108 L 200 94 L 300 90 L 398 102 L 468 124 L 498 180 L 506 250 L 490 318 L 458 372 L 412 406 L 360 430 L 300 438 L 250 420 L 220 446 L 188 414 L 150 390 L 120 350 L 98 298 L 82 244 L 72 196 Z";
const mineDots = [[455,262],[350,268],[107,196],[232,180],[338,176],[330,358],[288,340],[438,176]].map(([x,y])=>`<circle cx="${x}" cy="${y}" r="4" fill="#d9333f"/>`).join("");

const svgA = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}"><rect width="100%" height="100%" fill="#f5f2ec"/><path d="${mine}" fill="#fff" stroke="#111" stroke-width="1.5"/>${mineDots}<text x="12" y="${H-10}" font-size="14" font-family="Helvetica">CURRENT (hand-drawn)</text></svg>`;
const svgB = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}"><rect width="100%" height="100%" fill="#f5f2ec"/>${mun}${cty}${dots}<text x="12" y="${H-10}" font-size="14" font-family="Helvetica">REAL: geoBoundaries ADM2 (60) + ADM1 (10), Transverse Mercator 24E</text></svg>`;
fs.writeFileSync("cmp.html", `<html><head><meta charset=\"utf-8\"></head><body style="margin:0;display:flex;background:#fff">${svgA}${svgB}</body></html>`);
fs.writeFileSync("minecoords.json", JSON.stringify(mine));
console.log("real path chars:", real.length);
