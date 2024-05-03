import React, { useState, useEffect } from 'react';
import axios from 'axios';
import api from '../utils/api';
import '../index.css';
import { useNavigate } from 'react-router-dom';

export default function ShopScreen() {
    return (
        <div>
            <CategoryManager />
        </div>
    );
}

function CategoryManager() {
    const navigate = useNavigate()
    const [categories, setCategories] = useState([]);
    const [showForm, setShowForm] = useState(false);
    const [imagePreview, setImagePreview] = useState('');

    useEffect(() => {
        const fetchCategories = async () => {
            try {
                const response = await axios.get(api.fetchCategories);
                setCategories(response.data);
            } catch (error) {
                console.error('Failed to fetch categories:', error);
            }
        };

        fetchCategories();
    }, []);

    const handleImageChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onloadend = () => {
                setImagePreview(reader.result);
            };
            reader.readAsDataURL(file);
        }
    };

    const handleSubmitCategory = async (event) => {
        event.preventDefault();
        const formData = new FormData(event.target);
        try {
            const response = await axios.post(api.createCategory, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
            if (response.status === 200) {
                alert('Category added successfully!');
                setShowForm(false);
                setCategories([...categories, response.data]); // Assuming the server returns the new category
                setImagePreview(''); // Reset image preview after successful upload
            } else {
                alert('Failed to add category');
            }
        } catch (error) {
            console.error('Error submitting form', error);
            alert('Error submitting form');
        }
    };

    return (
        <center>
            <div className='category-list'>
                <div style={{ display: "flex", flexDirection: 'row', flexWrap: "wrap" }}>
                    {categories.map((category) => (
                        <div style={{ margin: 10 }} onClick={() => {
                            navigate("/ShopScreenSubcategory/"+category.category_id) // assuming you're using React Navigation

                        }}>
                            <span key={category.category_id}>
                                <img src={api.imageCategory + category.file_path} alt={category.name} style={{ objectFit: "contain" }} height={100} width={100} />
                                <div>{category.name}</div>
                            </span>
                        </div>
                    ))}
                </div>
                <button onClick={() => setShowForm(!showForm)}>Add Category</button>
            </div>
            {showForm && (
                <form onSubmit={handleSubmitCategory}>
                    <h1>Add Category</h1>
                    <input type='file' name='image' onChange={handleImageChange} required />
                    {imagePreview && <img src={imagePreview} alt="Preview" height={100} width={100} />}
                    <input type='text' name='name' placeholder='Enter category name' required />
                    <button type='submit'>Upload Image</button>
                </form>
            )}
        </center>
    );
}
