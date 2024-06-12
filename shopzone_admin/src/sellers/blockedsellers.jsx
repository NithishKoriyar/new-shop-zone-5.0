import React, { useEffect, useState } from 'react';
import axios from 'axios';
import unblockIcon from '../assets/images/activate.png'; // Import the unblock icon image

const BlockedSellers = () => {
  const [sellers, setSeller] = useState([]);
  const [showDialog, setShowDialog] = useState(false);
  const [selectedSellerId, setSelectedSellerId] = useState(null);

  useEffect(() => {
    fetchBlockedSellers();
  }, []);

  const fetchBlockedSellers = async () => {
    try {
      const response = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/adseller/blocked_seller.php');
      console.log('API Response:', response.data); // Log the response data
      // Ensure the response is an array
      if (Array.isArray(response.data)) {
        setSeller(response.data);
      } else {
        console.error('Unexpected response format:', response.data);
      }
    } catch (error) {
      console.error('Error fetching blocked users:', error);
    }
  };

  const confirmUnblockSeller = (sellerId) => {
    setSelectedSellerId(sellerId);
    setShowDialog(true);
  };

  const unblockSeller = async () => {
    try {
      await axios.post('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/adseller/unblock_seller.php', new URLSearchParams({ sellerId: selectedSellerId }));
      // Update the UI after unblocking the user
      setSeller(sellers.filter(seller => seller.seller_id !== selectedSellerId));
      alert('User unblocked successfully.');
      setShowDialog(false);
    } catch (error) {
      console.error('Error unblocking seller:', error);
      alert('Error unblocking seller.');
    }
  };

  return (
    <div>
      <div className="blocked-users-content">
        <h1>Blocked Users</h1>
        <div className="user-list">
          {sellers.length > 0 ? (
            sellers.map(seller => (
              <div key={seller.seller_id} className="user-item">
                <img src={"https://nithish.atozasindia.in/shop_zone_combination_api/seller/" + seller.seller_profile} alt={seller.seller_name} className="user-profile" />
                <div className="user-info">
                  <p>Name: {seller.seller_name}</p>
                  <p>Email: {seller.seller_email}</p>
                  <button onClick={() => confirmUnblockSeller(seller.seller_id)} className="unblock-button">
                    <img src={unblockIcon} alt="Unblock" className="unblock-icon" />
                    Unblock
                  </button>
                </div>
              </div>
            ))
          ) : (
            <p>No blocked users found.</p>
          )}
        </div>
      </div>
      {showDialog && (
        <div className="dialog">
          <div className="dialog-content">
            <p>Do you want to unblock this account?</p>
            <button onClick={() => setShowDialog(false)}>No</button>
            <button onClick={unblockSeller}>Yes</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default BlockedSellers;
