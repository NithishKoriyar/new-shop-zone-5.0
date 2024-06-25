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

const SellerPieChart = () => {
  const [sellerData, setSellerData] = useState({ verified: 0, blocked: 0 });

  useEffect(() => {
    const fetchSellerData = async () => {
      try {
        const verifiedResponse = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/adseller/Verifiedsellers.php');
        const blockedResponse = await axios.get('https://nithish.atozasindia.in/shop_zone_combination_api/Admin_web_portal/adseller/blocked_seller.php');

        setSellerData({
          verified: verifiedResponse.data.length,
          blocked: blockedResponse.data.length,
        });
      } catch (error) {
        console.error('Error fetching seller data:', error);
      }
    };

    fetchSellerData();
  }, []);

  const data = {
    labels: ['Verified Sellers', 'Blocked Sellers'],
    datasets: [
      {
        data: [sellerData.verified, sellerData.blocked],
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
        text: 'Seller Verification Status',
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

export default SellerPieChart;
