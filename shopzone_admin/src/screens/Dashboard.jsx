import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import verifiedUser from '../assets/images/verified_users.png';
import blockedUser from '../assets/images/blocked_users.png';
import verifiedSeller from '../assets/images/verified_seller.png';
import blockedSeller from '../assets/images/blocked_seller.png';
import '../index.css';

function Dashboard() {
  const [currentTime, setCurrentTime] = useState(new Date());
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const handleImageClick = (path) => {
    navigate(path);
  };

  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      <div className="dashboard-time">
        {currentTime.toLocaleTimeString()} <br />
        {currentTime.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })}
      </div>
      <div className="dashboard-images">
        <img
          src={verifiedUser}
          alt="Verified User"
          className="dashboard-image"
          onClick={() => handleImageClick('/verifiedusers')}
        />
        <img
          src={blockedUser}
          alt="Blocked User"
          className="dashboard-image"
          onClick={() => handleImageClick('/blockedusers')}
        />
        <img
          src={verifiedSeller}
          alt="Verified Seller"
          className="dashboard-image"
          onClick={() => handleImageClick('/verifiedsellers')}
        />
        <img
          src={blockedSeller}
          alt="Blocked Seller"
          className="dashboard-image"
          onClick={() => handleImageClick('/blockedsellers')}
        />
      </div>
    </div>
  );
}

export default Dashboard;
