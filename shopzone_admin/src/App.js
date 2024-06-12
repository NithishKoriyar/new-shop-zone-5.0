import React, { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Dashboard from "./screens/Dashboard";
import ShopScreen from "./screens/ShopScreen";
import FoodScreen from "./screens/FoodScreen";
import Navbar from "./components/Navbar";
import "./index.css";
import ShopScreenSubcategory from "./screens/ShoScreenSubcetodory";
import ImageUpload from "./screens/slider";
import LoginPage from "./screens/login";
import HomePage from "./screens/homepage";
import Sellerpiechart from "./screens/sellerpiechart";
import Userpiechart from "./screens/userpiechart";
import PrivateRoute from "./components/PrivateRoute";
import VerifiedUsers from "./users/verified_users";
 import BlockedUsers from "./users/blockedusers";
import Verifiedseller from "./sellers/verifiedseller";
import BlockedSellers from "./sellers/blockedsellers";

 

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  return (
    <BrowserRouter>
      {isLoggedIn && <Navbar setIsLoggedIn={setIsLoggedIn} />}
      <Routes>
        <Route path="*" element={<HomePage />} />
        <Route path="/" element={<HomePage setIsLoggedIn={setIsLoggedIn} />} />
        <Route path="/login" element={<LoginPage setIsLoggedIn={setIsLoggedIn} />} />
        <Route
          path="/dashboard"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<Dashboard />} />}
        />
        <Route
          path="/shop"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<ShopScreen />} />}
        />
        <Route
          path="/food"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<FoodScreen />} />}
        />
        <Route
          path="/ShopScreenSubcategory/:id"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<ShopScreenSubcategory />} />}
        />
        <Route
          path="/ImageUpload"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<ImageUpload />} />}
        />
        <Route
          path="/sellerpiechart"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<Sellerpiechart />} />}
        />
        <Route
          path="/userpiechart"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<Userpiechart />} />}
        />
        <Route
          path="/VerifiedUsers"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<VerifiedUsers />} />}
        />
        <Route
          path="/BlockedUsers"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<BlockedUsers />} />} 

          />
            <Route
          path="/VerifiedSellers"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<Verifiedseller />} />}
        />
        <Route
          path="/blockedsellers"
          element={<PrivateRoute isLoggedIn={isLoggedIn} element={<BlockedSellers />} />} 

          />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
