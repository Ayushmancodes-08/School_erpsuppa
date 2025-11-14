import { ImageResponse } from 'next/og';

// Image metadata
export const size = {
  width: 180,
  height: 180,
};
export const contentType = 'image/png';

// Image generation
export default function AppleIcon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'white',
        }}
      >
        <svg
          width="160"
          height="160"
          viewBox="0 0 64 64"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          {/* School Building */}
          <rect x="12" y="16" width="40" height="44" rx="2" fill="#2563eb" stroke="#1d4ed8" strokeWidth="2"/>
          
          {/* Roof/Top */}
          <path d="M8 16L32 4L56 16" fill="#1d4ed8" stroke="#1e40af" strokeWidth="2" strokeLinejoin="round"/>
          
          {/* Clock Circle */}
          <circle cx="32" cy="28" r="6" fill="white" stroke="#2563eb" strokeWidth="1.5"/>
          <circle cx="32" cy="28" r="1.5" fill="#2563eb"/>
          <line x1="32" y1="28" x2="32" y2="24" stroke="#2563eb" strokeWidth="1.5" strokeLinecap="round"/>
          
          {/* Door */}
          <rect x="26" y="46" width="12" height="14" rx="1" fill="#1e40af"/>
          <circle cx="35" cy="53" r="1" fill="white"/>
          
          {/* Windows */}
          <rect x="18" y="36" width="8" height="8" rx="1" fill="#60a5fa"/>
          <rect x="38" y="36" width="8" height="8" rx="1" fill="#60a5fa"/>
          <line x1="22" y1="36" x2="22" y2="44" stroke="#2563eb" strokeWidth="1"/>
          <line x1="18" y1="40" x2="26" y2="40" stroke="#2563eb" strokeWidth="1"/>
          <line x1="42" y1="36" x2="42" y2="44" stroke="#2563eb" strokeWidth="1"/>
          <line x1="38" y1="40" x2="46" y2="40" stroke="#2563eb" strokeWidth="1"/>
        </svg>
      </div>
    ),
    {
      ...size,
    }
  );
}
