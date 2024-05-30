// import React from 'react';
// import { useNavigate } from 'react-router-dom';
// import '../index.css';

// const HomePage = () => {
//   const navigate = useNavigate();

//   const handleAdminLogin = () => {
//     navigate('/login');
//   };

//   return (
//     <div className="home-page">
//       <div className="admin-login-container">
//         <button className="admin-login-button" onClick={handleAdminLogin}>
//           Admin Login
//         </button>
//       </div>
//       <h1>Welcome Admin Admin_web_portal system</h1>
//       <p></p>
//       <div className="button-container">
         
//         <button className="login-button" onClick={() => navigate('/login')}>
//           Login
//         </button>
//         <button className="admin-login-button" onClick={handleAdminLogin}>
//           Admin Login
//         </button>
//       </div>
//     </div>
//   );
// };

// export default HomePage;

import React from 'react';
import { useNavigate } from 'react-router-dom';
import '../index.css';

const HomePage = ({ setIsLoggedIn }) => {
  const navigate = useNavigate();

  const handleAdminLogin = () => {
    navigate('/login');
  };

  return (
    <div className="home-page">
      {/* <div className="admin-login-container">
        <button className="admin-login-button" onClick={handleAdminLogin}>
          Admin Login
        </button>
      </div> */}
      <h1>Welcome Admin Admin_web_portal system</h1>
      <p></p>
      <div className="button-container">
        <button className="login-button" onClick={handleAdminLogin}>
          Login
        </button>
      </div>
    </div>
  );
};

export default HomePage;
