import { WA_NUMBER, WA_MESSAGE } from '../config';

export function buildWaUrl(location: string): string {
  const base = `https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(WA_MESSAGE)}`;
  return location ? `${base}%20[${location}]` : base;
}

export function attachWaTracking(): void {
  document.addEventListener('click', (e) => {
    const target = e.target instanceof Element ? e.target.closest('[data-wa-location]') : null;
    if (!target) return;
    const location = target.getAttribute('data-wa-location') ?? 'unknown';
    console.log(`wa_click: ${location}`);
  });
}
