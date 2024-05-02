import { useState } from 'react';

function ImageUpload() {
    const [imagePreview, setImagePreview] = useState(null);
    const [isSubmitting, setIsSubmitting] = useState(false); // State to manage button enable/disable

    const handleImageChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                setImagePreview(e.target.result);
            };
            reader.readAsDataURL(file);
        }
    };

    const handleSubmit = (e) => {
      e.preventDefault();
      setIsSubmitting(true); // Disable the submit button to prevent multiple submissions
      const formData = new FormData();
      const fileField = document.querySelector('input[type="file"]');
      formData.append('image', fileField.files[0]);
  
      fetch('https://nithish.atozasindia.in/shop_zone_combination_api/user/normalUser/sliderImageupload.php', {
          method: 'POST',
          body: formData,
      })
      .then(response => response.json())
      .then(data => {
          setIsSubmitting(false); // Re-enable the button after receiving the response
          if (data.error) {
              console.error('Error:', data.error);
              alert('Failed to upload image.');
          } else {
              console.log('Success:', data.message);
              alert('Image uploaded successfully!');
          }
      })
      .catch((error) => {
          setIsSubmitting(false); // Re-enable the button if there's an error in the network request
          console.error('Error parsing JSON:', error);
          alert('Error processing your request.');
      });
  };
  
    return (
        <div>
            <form onSubmit={handleSubmit}>
                <input type='file' onChange={handleImageChange} disabled={isSubmitting} />
                <button type='submit' disabled={isSubmitting}>Upload Image</button>
            </form>
            {imagePreview && <img src={imagePreview} alt="Preview" />}
        </div>
    );
}

export default ImageUpload;
