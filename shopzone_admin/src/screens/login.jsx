import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import '../index.css'; // Import your CSS file here
import adminImage from '../assets/images/admin.png'; 

const LoginPage = ({ setIsLoggedIn }) => {
  const navigate = useNavigate();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = async (event) => {
    event.preventDefault();
    try {
      const response = await axios.post('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/login.php', {
        username,
        password
      });
      console.log(response)
      if(response.data.status === 'success'){
        alert(response.data.message)
        localStorage.setItem('token', response.data.token);
        setIsLoggedIn(true);
        navigate('/dashboard'); // Redirect to dashboard or any other page after login
      }else{
        alert(response.data.message)
      }
     
   
    } catch (error) {
      setError("Invalid username or password");
    }
  };

  return (
    <>
      <div className="login-form">
        <div className="form-container">
          <center>
            <img src={adminImage} alt="Admin" style={{ width: '250px', height: '250px', marginBottom: '20px' }} />
            <form className="login" onSubmit={handleSubmit}>
              <input
                placeholder="Enter Username"
                type="text"
                name="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                className="input-field"
              /><br />
              <input
                placeholder="Enter Password"
                type="password"
                name="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="input-field"
              /><br />
              <input type="submit" value="Login" className="submit-button" />
            </form>
          </center>
        </div>
      </div>
      {error && <p className="error-message">{error}</p>}
    </>
  );
}

export default LoginPage;


