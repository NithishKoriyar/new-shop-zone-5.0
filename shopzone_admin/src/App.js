// // import React from "react";
// // import { BrowserRouter, Routes, Route } from "react-router-dom";
// // import Dashboard from "./screens/Dashboard";
// // import ShopScreen from "./screens/ShopScreen";
// // import FoodScreen from "./screens/FoodScreen";
// // import Navbar from "./components/Navbar";
// // import "./index.css"
// // import ShopScreenSubcategory from "./screens/ShoScreenSubcetodory";
// // import ImageUpload from "./screens/slider";
// // import LoginPage from "./screens/login";

// // import HomePage from "./screens/homepage";

// // function App() {
// //   return (
// //     <BrowserRouter>
// //      <Navbar/>
// //     <Routes>
// //     <Route path="/" element={<HomePage />} />
  
// //       <Route path="/dashboard" element={<Dashboard/>}/>
// //         <Route path="/shop" element={<ShopScreen/>} />
// //         <Route path="/food" element={<FoodScreen/>} />
// //         <Route path="/ShopScreenSubcategory/:id" element={<ShopScreenSubcategory/>} />
// //         <Route path="/ImageUpload" element={<ImageUpload/>} />
// //         <Route path="/login" element={<LoginPage/>} />


// //     </Routes>
// //   </BrowserRouter>
// //   );
// // }

// // export default App;


// // import  { useState } from 'react';

// // function ImageUpload() {
// //     const [imagePreview, setImagePreview] = useState(null);

// //     const handleImageChange = (e) => {
// //         const file = e.target.files[0];
// //         if (file) {
// //             const reader = new FileReader();
// //             reader.onload = (e) => {
// //                 setImagePreview(e.target.result);
// //             };
// //             reader.readAsDataURL(file);
// //         }
// //     };

// //     const handleSubmit = (e) => {
// //       e.preventDefault();
// //       const formData = new FormData();
// //       const fileField = document.querySelector('input[type="file"]');
// //       formData.append('image', fileField.files[0]);
  
// //       fetch('https://nithish.atozasindia.in/shop_zone_combination_api/user/normalUser/upload.php', {
// //           method: 'POST',
// //           body: formData,
// //       })
// //       .then(response => response.json())
// //       .then(data => {
// //           if (data.error) {
// //               console.error('Error:', data.error);
// //           } else {
// //               console.log('Success:', data.message);
// //           }
// //       })
// //       .catch((error) => {
// //           console.error('Error parsing JSON:', error);
// //       });
// //   };
  
// //     return (
// //         <div>
// //             <form onSubmit={handleSubmit}>
// //                 <input type='file' onChange={handleImageChange} />
// //                 <button type='submit'>Upload Image</button>
// //             </form>
// //             {imagePreview && <img src={imagePreview} alt="Preview" />}
// //         </div>
// //     );
// // }

// // export default ImageUpload;


// //000000000000
// import React, { useState } from "react";
// import { BrowserRouter, Routes, Route } from "react-router-dom";
// import Dashboard from "./screens/Dashboard";
// import ShopScreen from "./screens/ShopScreen";
// import FoodScreen from "./screens/FoodScreen";
// import Navbar from "./components/Navbar";
// import "./index.css";
// import ShopScreenSubcategory from "./screens/ShoScreenSubcetodory";
// import ImageUpload from "./screens/slider";
// import LoginPage from "./screens/login";
// import HomePage from "./screens/homepage";
// import Sellerpiechart from "./screens/sellerpiechart";
// import Userpiechart from "./screens/userpiechart";



// function App() {
//   const [isLoggedIn, setIsLoggedIn] = useState(false);

//   return (
//     <BrowserRouter>
//       {isLoggedIn && <Navbar />}
//       <Routes>
//         <Route path="/" element={<HomePage setIsLoggedIn={setIsLoggedIn} />} />
//         <Route path="/dashboard" element={<Dashboard />} />
//         <Route path="/shop" element={<ShopScreen />} />
//         <Route path="/food" element={<FoodScreen />} />
//         <Route path="/ShopScreenSubcategory/:id" element={<ShopScreenSubcategory />} />
//         <Route path="/ImageUpload" element={<ImageUpload />} />
//         <Route path="/login" element={<LoginPage setIsLoggedIn={setIsLoggedIn} />} />
//         <Route path="/sellerpiechart" element={<Sellerpiechart />} />
//         <Route path="/userpiechart" element={<Userpiechart />} />
//       </Routes>
//     </BrowserRouter>
//   );
// }

// export default App;


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


function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  return (
    <BrowserRouter>
      {isLoggedIn && <Navbar />}
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
      </Routes>
    </BrowserRouter>
  );
}

export default App;


