import React, { useEffect, useState } from 'react';
import axios from 'axios';
import blockIcon from '../assets/images/block.png'; // Import the block icon image

const VerifiedUsers = () => {
  const [users, setUsers] = useState([]);
  const [showDialog, setShowDialog] = useState(false);
  const [selectedUserId, setSelectedUserId] = useState(null);

  useEffect(() => {
    fetchApprovedUsers();
  }, []);

  const fetchApprovedUsers = async () => {
    try {
      const response = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/VerifiedUsers.php');
      // Ensure the response is an array
      if (Array.isArray(response.data)) {
        setUsers(response.data);
      } else {
        console.error('Unexpected response format:', response.data);
      }
    } catch (error) {
      console.error('Error fetching approved users:', error);
    }
  };

  const confirmBlockUser = (userId) => {
    setSelectedUserId(userId);
    setShowDialog(true);
  };

  const blockUser = async () => {
    try {
      await axios.post('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/block_user.php', new URLSearchParams({ userId: selectedUserId }));
      // Update the UI after blocking the user
      setUsers(users.filter(user => user.user_id !== selectedUserId));
      alert('You blocked successfully.');
      setShowDialog(false);
    } catch (error) {
      console.error('Error blocking user:', error);
      alert('Error blocking user.');
    }
  };

  return (
    <div>
      <div className="verified-users-content">
        <h1>Verified Users</h1>
        <div className="user-list">
          {users.map(user => (
            <div key={user.user_id} className="user-item">
              <img src={"https://nithish.atozasindia.in/shop_zone_combination_api/user/" + user.user_profile} alt={user.user_name} className="user-profile" />
              <div className="user-info">
                <p>Name: {user.user_name}</p>
                <p>Email: {user.user_email}</p>
                <button onClick={() => confirmBlockUser(user.user_id)} className="block-button">
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
            <button onClick={blockUser}>Yes</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default VerifiedUsers;
