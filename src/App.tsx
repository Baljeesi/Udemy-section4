import React from 'react';
import Dashboard from './components/Dashboard';
import './index.css';

function App() {
  // Title update
  React.useEffect(() => {
    document.title = "CI/CD Dashboard - Baljeet Singh";
  }, []);

  return (
    <Dashboard />
  );
}

export default App;
