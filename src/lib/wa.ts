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
    
    if (typeof window.gtag === 'function') {
      window.gtag('event', 'wa_click', { location });
    }
  });
}

export function attachScrollTracking(): void {
  let tracked75 = false;
  
  const checkScroll = () => {
    const scrollPercent = (window.scrollY + window.innerHeight) / document.documentElement.scrollHeight * 100;
    
    if (!tracked75 && scrollPercent >= 75) {
      tracked75 = true;
      if (typeof window.gtag === 'function') {
        window.gtag('event', 'scroll_depth', { percent: 75 });
      }
    }
  };
  
  window.addEventListener('scroll', checkScroll, { passive: true });
}

export function attachTimeTracking(): void {
  setTimeout(() => {
    if (typeof window.gtag === 'function') {
      window.gtag('event', 'time_on_page', { seconds: 60 });
    }
  }, 60000);
}
