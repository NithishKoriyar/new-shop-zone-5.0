import React, { useState, useEffect } from 'react';
import axios from 'axios';
import api from '../utils/api';
import '../index.css';
import { useParams } from 'react-router-dom';


export default function ShopScreenSubcategory() {
    const {id} = useParams()
   
    return (
        <div>
            <SubCategoryPanel id={id}/>
        </div>
    );
}

function SubCategoryPanel({id}) {

    const [SubCategories, setSubCategories] = useState([]);
    const [showForm, setShowForm] = useState(false);
    const [imagePreview, setImagePreview] = useState('');

    useEffect(() => {
        const fetchSubCategories = async () => {
            try {
                // Assuming 'id' is available in this scope; otherwise, you'll need to define it.
                const response = await axios.get(api.fetchSubCategories, { 
                    params: { id: id }  // Here you specify the 'id' as a query parameter
                });
                setSubCategories(response.data);
                console.table(response.data);
            } catch (error) {
                console.error('Failed to fetch SubCategories:', error);
            }
        };
    
        fetchSubCategories();
    }, [id]);  // Add 'id' as a dependency if it's not static
    

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
            const response = await axios.post(api.createSubCategory, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
            if (response.status === 200) {
                alert('Category added successfully!');
                setShowForm(false);
                setSubCategories([...SubCategories, response.data]); // Assuming the server returns the new subCategory
                setImagePreview(''); // Reset image preview after successful upload
            } else {
                alert('Failed to add subCategory');
            }
        } catch (error) {
            console.error('Error submitting form', error);
            alert('Error submitting form');
        }
    };
    console.log(SubCategories)

    return (
        <center>
            <div className='category-list'>
                <div style={{display:"flex",flexDirection:'row',flexWrap:"wrap"}}>
                    {SubCategories.map((subCategory) => (
                        <div style={{margin:10}}>
                            <span key={subCategory.category_id}>
                                <img src={api.imageCategory + subCategory.img_path} alt={subCategory.name} style={{ objectFit: "contain" }} height={100} width={100} />
                                <div>{subCategory.name}</div>
                            </span>
                        </div>
                    ))}
                </div>
                <button onClick={() => setShowForm(!showForm)}>Add Subcategory</button>
            </div>
            {showForm && (
                <form onSubmit={handleSubmitCategory}>
                    <h1>Add Category</h1>
                    <input type='file' name='image' onChange={handleImageChange} required />
                    {imagePreview && <img src={imagePreview} alt="Preview" height={100} width={100} />}
                    <input type='text' name='categoryId' placeholder='Enter subCategory name' value={id} />
                    <input type='text' name='name' placeholder='Enter subCategory name' required />
                    <button type='submit'>Upload Image</button>
                </form>
            )}
        </center>
    );
}
