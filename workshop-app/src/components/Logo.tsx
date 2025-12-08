import { useConfig } from '@/contexts/ConfigContext'

export function Logo() {
  const { config } = useConfig()
  
  switch (config.branding.logo) {
    case 'tmux':
      return <TmuxLogo />
    case 'redhat':
      return <RedHatLogo />
    case 'openshift':
      return <OpenShiftLogo />
    case 'custom':
      return config.branding.customLogoUrl ? (
        <img src={config.branding.customLogoUrl} alt={config.branding.name} className="h-8" />
      ) : <OpenShiftLogo />
    default:
      return <OpenShiftLogo />
  }
}

function TmuxLogo() {
  return (
    <div className="flex items-center gap-3">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-8 w-8 text-green-500">
        <rect x="2" y="4" width="20" height="16" rx="2" ry="2"/>
        <line x1="6" y1="8" x2="6" y2="8"/>
        <line x1="10" y1="8" x2="10" y2="8"/>
        <line x1="14" y1="8" x2="14" y2="8"/>
        <path d="M6 12l4 4"/>
        <path d="M6 16l4-4"/>
        <line x1="14" y1="16" x2="18" y2="16"/>
      </svg>
      <span className="text-white font-bold text-xl whitespace-nowrap font-mono">
        tmux
      </span>
    </div>
  )
}

function RedHatLogo() {
  return (
    <div className="flex items-center gap-3">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 180" className="h-10 w-auto flex-shrink-0">
        <path fill="#e00" d="M127 90.2c12.5 0 30.6-2.6 30.6-17.5a12.678 12.678 0 0 0-.3-3.4L149.8 37c-1.7-7.1-3.2-10.3-15.7-16.6-9.7-5-30.8-13.1-37.1-13.1-5.8 0-7.5 7.5-14.4 7.5-6.7 0-11.6-5.6-17.9-5.6-6 0-9.9 4.1-12.9 12.5 0 0-8.4 23.7-9.5 27.2a4.216 4.216 0 0 0-.3 1.9c0 9.2 36.3 39.4 85 39.4Zm32.5-11.4c1.7 8.2 1.7 9.1 1.7 10.1 0 14-15.7 21.8-36.4 21.8-46.8 0-87.7-27.4-87.7-45.5a17.535 17.535 0 0 1 1.5-7.3C21.8 58.8 0 61.8 0 81c0 31.5 74.6 70.3 133.7 70.3 45.3 0 56.7-20.5 56.7-36.6-.1-12.8-11-27.3-30.9-35.9Z"/>
        <path fill="#000" d="M159.5 78.8c1.7 8.2 1.7 9.1 1.7 10.1 0 14-15.7 21.8-36.4 21.8-46.8 0-87.7-27.4-87.7-45.5a17.535 17.535 0 0 1 1.5-7.3l3.7-9.1a4.877 4.877 0 0 0-.3 2c0 9.2 36.3 39.4 85 39.4 12.5 0 30.6-2.6 30.6-17.5a12.678 12.678 0 0 0-.3-3.4Z"/>
      </svg>
      <span className="text-white font-medium text-lg whitespace-nowrap" style={{ fontFamily: "'Red Hat Display', sans-serif" }}>
        Red Hat
      </span>
    </div>
  )
}

function OpenShiftLogo() {
  return (
    <div className="flex items-center gap-3">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" className="h-8 w-8 flex-shrink-0">
        <path fill="#e00" d="M21.665 11.812L20.24 6.27a2.247 2.247 0 00-1.094-1.417 2.25 2.25 0 00-1.773-.182l-2.028.612a7.496 7.496 0 00-6.69 0l-2.028-.612a2.25 2.25 0 00-1.773.182 2.247 2.247 0 00-1.094 1.417L2.335 11.812a2.25 2.25 0 00.364 1.888 2.254 2.254 0 001.693.955l.54.038a7.487 7.487 0 003.345 5.788l-.244 1.959a2.25 2.25 0 00.571 1.74 2.25 2.25 0 001.665.82h3.462a2.25 2.25 0 001.665-.82 2.25 2.25 0 00.571-1.74l-.244-1.96a7.487 7.487 0 003.345-5.787l.54-.038a2.254 2.254 0 001.693-.955 2.25 2.25 0 00.364-1.888z"/>
      </svg>
      <span className="text-white font-medium text-lg whitespace-nowrap" style={{ fontFamily: "'Red Hat Display', sans-serif" }}>
        OpenShift
      </span>
    </div>
  )
}
