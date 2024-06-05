// import React from "react";
// import { Link } from "react-router-dom";

// // function Navbar() {
// //   return (
// //     <nav>
// //       <ul>
// //         <li><Link to="/">Dashboard</Link></li>
// //         <li><Link to="/shop">Shop</Link></li>
// //         <li><Link to="/food">Food</Link></li>
// //         <li><Link to="/ImageUpload">slider</Link></li>
     
// //       </ul>
// //     </nav>
// //   );
// // }
// function Navbar() {
//   return (
//     <nav className="navbar">
//       <ul className="navbar-menu">
//         <li className="navbar-item"><Link to="/dashboard">Dashboard</Link></li>
//         <li className="navbar-item"><Link to="/shop">Shop</Link></li>
//         <li className="navbar-item"><Link to="/food">Food</Link></li>
//         <li className="navbar-item"><Link to="/ImageUpload">Slider</Link></li>
//         <li className="navbar-item"><Link to="/sellerpiechart">sellerpiechart</Link></li>
//         <li className="navbar-item"><Link to="/userpiechart">usepiechart</Link></li>
//       </ul>
//     </nav>
//   );
// }

// export default Navbar;



import React from "react";
import { Link, useNavigate } from "react-router-dom";

function Navbar({setIsLoggedIn}) {
  const navigate = useNavigate();

  const handleLogout = () => {
    // Implement your logout logic here, for example clearing user session or tokens
    console.log("User logged out");
    setIsLoggedIn(false)
    // Redirect to the home screen
    navigate("/");
  };

  return (
    <nav className="navbar">
      <ul className="navbar-menu">
        <li className="navbar-item"><Link to="/dashboard">Dashboard</Link></li>
        <li className="navbar-item"><Link to="/shop">Shop</Link></li>
        <li className="navbar-item"><Link to="/food">Food</Link></li>
        <li className="navbar-item"><Link to="/ImageUpload">Slider</Link></li>
        <li className="navbar-item"><Link to="/sellerpiechart">Seller Pie Chart</Link></li>
        <li className="navbar-item"><Link to="/userpiechart">User Pie Chart</Link></li>
        <li className="navbar-item"><button onClick={handleLogout} className="logout-button">Logout</button></li>
      </ul>
    </nav>
  );
}

export default Navbar;

