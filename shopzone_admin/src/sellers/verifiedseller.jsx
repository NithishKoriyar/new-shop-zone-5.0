import React, { useState, useEffect } from 'react';
import axios from 'axios';
import blockIcon from '../assets/images/block.png';
import earningsIcon from '../assets/images/earnings.png';

function Verifiedseller() {
  const [sellers, setSeller] = useState([]);
  const [showDialog, setShowDialog] = useState(false);
  const [selectedSellerId, setSelectedSellerId] = useState(null);


  useEffect(() => {
    fetchApprovedSellers();
  }, []);

  const fetchApprovedSellers = async () => {
    try {
      const response = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/adseller/Verifiedsellers.php');
      // console.log('API Response:', response.data);
      if (Array.isArray(response.data)) {
        setSeller(response.data);
        console.table(response.data)
      } else {
        console.error('Unexpected response format:', response.data);
      }
    } catch (error) {
      console.error('Error fetching approved users:', error);
    }
  };




  const confirmBlockSeller = (sellerId) => {
    setSelectedSellerId(sellerId);
        setShowDialog(true);
  };

  const blockSeller = async () => {
    try {
      await axios.post('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/adseller/block_seller.php', new URLSearchParams({ sellerId: selectedSellerId }));
      setSeller(sellers.filter(seller => seller.seller_id !== selectedSellerId));
      alert('You blocked successfully.');
      setShowDialog(false);
    } catch (error) {
      console.error('Error blocking user:', error);
      alert('Error blocking user.');
    }
  };

  return (
    <div>
      <div className="verified-sellers-content">
        <h1>Verified Sellers</h1>
        <div className="seller-list">
          {sellers.map(seller => (
            <div key={seller.seller_id} className="seller-item">
              <img src={`https://nithish.atozasindia.in/shop_zone_combination_api/seller/${seller.seller_profile}`} alt={seller.seller_name} className="seller-profile" />
              <div className="user-info">
                <p>Name: {seller.seller_name}</p>
                <p>Email: {seller.seller_email}</p>
                <div className='CC'>
                  <img src={earningsIcon} alt="Earnings" className="earnings-icon" />
                  <p>Earnings: {seller.earnings.toLocaleString('en-IN')}</p>
                </div>

                <button onClick={() => confirmBlockSeller(seller.seller_id)} className="block-button">
                  <img src={blockIcon} alt="Block" className="block-icon" />
                  Block
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
      {showDialog && (
        <div className="dialog">
          <div className="dialog-content">
            <p>Do you want to block this account?</p>
           
            <button onClick={() => setShowDialog(false)}>No</button>
            <button onClick={blockSeller}>Yes</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default Verifiedseller;
