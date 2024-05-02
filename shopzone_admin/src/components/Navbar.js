import React from "react";
import { Link } from "react-router-dom";

function Navbar() {
  return (
    <nav>
      <ul>
        <li><Link to="/">Dashboard</Link></li>
        <li><Link to="/shop">Shop</Link></li>
        <li><Link to="/food">Food</Link></li>
        <li><Link to="/ImageUpload">slider</Link></li>
      </ul>
    </nav>
  );
}

export default Navbar;
