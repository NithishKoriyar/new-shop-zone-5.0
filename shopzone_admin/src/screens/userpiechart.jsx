import React, { useEffect, useState } from 'react';
import { Pie } from 'react-chartjs-2';
import axios from 'axios';
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
  Title
} from 'chart.js';

ChartJS.register(ArcElement, Tooltip, Legend, Title);

const Userpiechart = () => {
  const [userData, setUserData] = useState({ approved: 0, notApproved: 0 });

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        const approvedResponse = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/aduser/approved_users_endpoint.php');
        const notApprovedResponse = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/aduser/not_approved_users_endpoint.php');

        setUserData({
          approved: approvedResponse.data.length,
          notApproved: notApprovedResponse.data.length,
        });
      } catch (error) {
        console.error('Error fetching user data:', error);
      }
    };

    fetchUserData();
  }, []);

  const data = {
    labels: ['Approved Users', 'Not Approved Users'],
    datasets: [
      {
        data: [userData.approved, userData.notApproved],
        backgroundColor: ['#36A2EB', '#FF6384'],
        hoverBackgroundColor: ['#36A2EB', '#FF6384'],
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'right',
        labels: {
          font: {
            size: 14,
          },
        },
      },
      title: {
        display: true,
        text: 'User Approval Status',
        font: {
          size: 18,
        },
      },
    },
  };

  return (
    <div style={{ width: '100%', height: '500px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
      <div style={{ width: '50%', height: '100%' }}>
        <Pie data={data} options={options} />
      </div>
    </div>
  );
};

export default Userpiechart;
