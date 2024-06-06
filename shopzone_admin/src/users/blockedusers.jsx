import React, { useEffect, useState } from 'react';
import axios from 'axios';
import unblockIcon from '../assets/images/activate.png'; // Import the unblock icon image

const BlockedUsers = () => {
  const [users, setUsers] = useState([]);
  const [showDialog, setShowDialog] = useState(false);
  const [selectedUserId, setSelectedUserId] = useState(null);

  useEffect(() => {
    fetchBlockedUsers();
  }, []);

  const fetchBlockedUsers = async () => {
    try {
      const response = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/block_user.php');
      // Ensure the response is an array
      if (Array.isArray(response.data)) {
        setUsers(response.data);
      } else {
        console.error('Unexpected response format:', response.data);
      }
    } catch (error) {
      console.error('Error fetching blocked users:', error);
    }
  };

  const confirmUnblockUser = (userId) => {
    setSelectedUserId(userId);
    setShowDialog(true);
  };

  const unblockUser = async () => {
    try {
      await axios.post('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/unblock_user.php', new URLSearchParams({ userId: selectedUserId }));
      // Update the UI after unblocking the user
      setUsers(users.filter(user => user.user_id !== selectedUserId));
      alert('User unblocked successfully.');
      setShowDialog(false);
    } catch (error) {
      console.error('Error unblocking user:', error);
      alert('Error unblocking user.');
    }
  };

  return (
    <div>
      <div className="blocked-users-content">
        <h1>Blocked Users</h1>
        <div className="user-list">
          {users.map(user => (
            <div key={user.user_id} className="user-item">
              <img src={"https://nithish.atozasindia.in/shop_zone_combination_api/user/" + user.user_profile} alt={user.user_name} className="user-profile" />
              <div className="user-info">
                <p>Name: {user.user_name}</p>
                <p>Email: {user.user_email}</p>
                <button onClick={() => confirmUnblockUser(user.user_id)} className="unblock-button">
                  <img src={unblockIcon} alt="Unblock" className="unblock-icon" />
                  Unblock
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
      {showDialog && (
        <div className="dialog">
          <div className="dialog-content">
            <p>Do you want to unblock this account?</p>
            <button onClick={() => setShowDialog(false)}>No</button>
            <button onClick={unblockUser}>Yes</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default BlockedUsers;
