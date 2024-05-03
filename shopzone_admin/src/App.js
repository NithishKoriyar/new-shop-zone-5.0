import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Dashboard from "./screens/Dashboard";
import ShopScreen from "./screens/ShopScreen";
import FoodScreen from "./screens/FoodScreen";
import Navbar from "./components/Navbar";
import "./index.css"
import ShopScreenSubcategory from "./screens/ShoScreenSubcetodory";
import ImageUpload from "./screens/slider";
function App() {
  return (
    <BrowserRouter>
     <Navbar/>
    <Routes>
   
      <Route path="/" element={<Dashboard/>}/>
        <Route path="/shop" element={<ShopScreen/>} />
        <Route path="/food" element={<FoodScreen/>} />
        <Route path="/ShopScreenSubcategory/:id" element={<ShopScreenSubcategory/>} />
        <Route path="/ImageUpload" element={<ImageUpload/>} />

    </Routes>
  </BrowserRouter>
  );
}

export default App;


// import  { useState } from 'react';

// function ImageUpload() {
//     const [imagePreview, setImagePreview] = useState(null);

//     const handleImageChange = (e) => {
//         const file = e.target.files[0];
//         if (file) {
//             const reader = new FileReader();
//             reader.onload = (e) => {
//                 setImagePreview(e.target.result);
//             };
//             reader.readAsDataURL(file);
//         }
//     };

//     const handleSubmit = (e) => {
//       e.preventDefault();
//       const formData = new FormData();
//       const fileField = document.querySelector('input[type="file"]');
//       formData.append('image', fileField.files[0]);
  
//       fetch('https://nithish.atozasindia.in/shop_zone_combination_api/user/normalUser/upload.php', {
//           method: 'POST',
//           body: formData,
//       })
//       .then(response => response.json())
//       .then(data => {
//           if (data.error) {
//               console.error('Error:', data.error);
//           } else {
//               console.log('Success:', data.message);
//           }
//       })
//       .catch((error) => {
//           console.error('Error parsing JSON:', error);
//       });
//   };
  
//     return (
//         <div>
//             <form onSubmit={handleSubmit}>
//                 <input type='file' onChange={handleImageChange} />
//                 <button type='submit'>Upload Image</button>
//             </form>
//             {imagePreview && <img src={imagePreview} alt="Preview" />}
//         </div>
//     );
// }

// export default ImageUpload;
