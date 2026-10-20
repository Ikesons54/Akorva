export default function Logo({ size = 96, animate = false }: { size?: number; animate?: boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" role="img" aria-label="Akorva logo">
      <rect width="100" height="100" rx="22" fill="#2B3A33" />
      <path className={animate ? "draw" : undefined} pathLength={1} d="M28 72 L50 26 L72 72"
        fill="none" stroke="#C9B079" strokeWidth="7" strokeLinecap="round" strokeLinejoin="round" />
      <path className={animate ? "draw late" : undefined} pathLength={1} d="M38 58 H62"
        fill="none" stroke="#C9B079" strokeWidth="6" strokeLinecap="round" />
      <path d="M30 83 H70" stroke="#C9B079" strokeWidth="3" strokeLinecap="round" opacity="0.55" />
    </svg>
  );
}
