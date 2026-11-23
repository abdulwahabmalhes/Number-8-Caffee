import { LockKeyhole, ShieldCheck } from 'lucide-react';
import { FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';

export function LoginPage() {
  const navigate = useNavigate();
  const submit = (event: FormEvent) => {
    event.preventDefault();
    navigate('/');
  };

  return <main className="login-page"><section className="login-art" aria-label="Restaurant operations artwork"><img src="/assets/erp-login-art.png" alt="Abstract restaurant operations illustration"/><div className="login-art__copy"><span>NUMBER EIGHT</span><h1>One operation.<br/>Every detail connected.</h1><p>Restaurant control designed for speed at the counter and clarity in the office.</p></div></section><section className="login-card-wrap"><form className="login-card" onSubmit={submit}><img className="login-logo" src="/assets/number-eight-logo.png" alt="NUMBER EIGHT"/><span className="demo-badge">DEVELOPMENT DEMO</span><h2>Welcome back</h2><p>Sign in to your restaurant workspace.</p><label>Work email<input type="email" required placeholder="name@restaurant.com" autoComplete="username"/></label><label>Password<input type="password" required placeholder="••••••••" autoComplete="current-password"/></label><div className="login-options"><label><input type="checkbox"/> Keep me signed in</label><button type="button">Forgot password?</button></div><button className="primary-button login-submit" type="submit"><LockKeyhole size={17}/>Continue in demo mode</button><div className="login-security"><ShieldCheck size={17}/><span>Production authentication is intentionally not connected.</span></div></form></section></main>;
}
