import React, { useState } from 'react';

function FoodScreen() {
  const [showCategory, setShowCategory] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState('');
  const [selectedSubcategory, setSelectedSubcategory] = useState('');

  const categories = {
    Electronics: ["TV", "Refrigerator", "Laptop"],
    Medical: ["Syringes", "Bandages", "Gloves"],
    Fashion: ["Shirts", "Pants", "Shoes"]
  };

  // Function to handle showing the category button
  const handlePlusClick = () => {
    setShowCategory(true);
  };

  // Function to handle category selection
  const handleCategoryClick = (category) => {
    setSelectedCategory(category);
    setSelectedSubcategory(''); // Reset subcategory selection when category changes
  };

  // Function to handle subcategory selection
  const handleSubcategoryClick = (subcategory) => {
    setSelectedSubcategory(subcategory);
  };

  return (
    <div>
      <h1>FoodScreen</h1>
      <button onClick={handlePlusClick}>+</button>
      {showCategory && (
        <div>
          <button onClick={() => handleCategoryClick('Electronics')}>Electronics</button>
          <button onClick={() => handleCategoryClick('Medical')}>Medical</button>
          <button onClick={() => handleCategoryClick('Fashion')}>Fashion</button>
        </div>
      )}
      {selectedCategory && (
        <div>
          <h2>Select a subcategory in {selectedCategory}:</h2>
          <select onChange={(e) => handleSubcategoryClick(e.target.value)}>
            <option value="">Select Subcategory</option>
            {categories[selectedCategory].map(subcat => (
              <option key={subcat} value={subcat}>{subcat}</option>
            ))}
          </select>
        </div>
      )}
      {selectedSubcategory && (
        <h2>You selected: {selectedSubcategory}</h2>
      )}
    </div>
  );
}

export default FoodScreen;
