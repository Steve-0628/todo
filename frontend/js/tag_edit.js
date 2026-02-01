import { apiCall, renderNavbar } from './common.js';

const tagId = window.location.pathname.split('/').filter(Boolean).pop();
const tagNameInput = document.getElementById('tagName');
const statusMessage = document.getElementById('statusMessage');
const saveBtn = document.getElementById('saveBtn');

async function fetchTag() {
    try {
        const tag = await apiCall(`/tags/${tagId}`);
        tagNameInput.value = tag.name;
    } catch (error) {
        statusMessage.innerText = 'Failed to load tag.';
    }
}

async function handleSave() {
    const name = tagNameInput.value;
    
    if (!name.trim()) {
        statusMessage.innerText = 'Name is required.';
        return;
    }

    try {
        await apiCall(`/tags/${tagId}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name })
        });
        window.location.href = '/tag/';
    } catch (error) {
        statusMessage.innerText = 'Failed to update tag.';
    }
}

function init() {
    renderNavbar();
    fetchTag();
    saveBtn.addEventListener('click', handleSave);
}

init();
