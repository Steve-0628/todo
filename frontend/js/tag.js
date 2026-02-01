import { apiCall, renderNavbar } from './common.js';

const tagNameInput = document.getElementById('tagName');
const statusMessage = document.getElementById('statusMessage');
const createBtn = document.getElementById('createBtn');
const tagList = document.getElementById('tagList');

async function fetchTags() {
    try {
        const tags = await apiCall('/tags');
        renderTags(tags);
    } catch (error) {
        tagList.innerText = 'Failed to load tags.';
    }
}

function renderTags(tags) {
    tagList.innerText = '';
    if (tags.length === 0) {
        tagList.innerText = 'No tags found.';
        return;
    }

    tags.forEach(tag => {
        const div = document.createElement('div');
        div.className = 'todo-item'; // Reuse existing class for basic styling
        
        const link = document.createElement('a');
        link.href = `/tag/edit/${tag.id}`;
        link.innerText = tag.name;
        link.className = 'todo-link'; // Reuse existing class
        
        div.appendChild(link);
        tagList.appendChild(div);
    });
}

async function handleCreate() {
    const name = tagNameInput.value;
    
    if (!name) return;

    try {
        await apiCall('/tags', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name })
        });
        tagNameInput.value = '';
        fetchTags(); // Refresh list
    } catch (error) {
        statusMessage.innerText = 'Failed to create tag.';
    }
}

function init() {
    renderNavbar();
    fetchTags();
    createBtn.addEventListener('click', handleCreate);
}

init();
