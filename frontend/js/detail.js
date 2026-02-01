import { apiCall, renderNavbar } from './common.js';

const todoId = window.location.pathname.split('/').filter(Boolean).pop();

const detailView = document.getElementById('detailView');
const todoTitle = document.getElementById('todoTitle');
const todoContent = document.getElementById('todoContent');
const editLink = document.getElementById('editLink');
const createdDate = document.getElementById('createdDate');
const statusIcon = document.getElementById('statusIcon');
const tagsContainer = document.getElementById('tagsContainer');
const parentContainer = document.getElementById('parentContainer');
const parentLink = document.getElementById('parentLink');
const childrenContainer = document.getElementById('childrenContainer');
const childrenList = document.getElementById('childrenList');

async function fetchTodo() {
    try {
        const data = await apiCall(`/todos/${todoId}`);
        renderTodo(data.result);
    } catch (error) {
        detailView.innerText = '';
        const div = document.createElement('div');
        div.className = 'error';
        div.innerText = 'Failed to load todo.';
        detailView.appendChild(div);
    }
}

function renderTodo(todo) {
    // Basic Info
    todoTitle.innerText = todo.title;
    todoContent.innerText = todo.content || '';
    
    // Edit Link
    editLink.href = `/edit/${todo.id}`;
    editLink.style.display = 'inline';

    // Dates & Status
    createdDate.innerText = new Date(todo.createdAt).toLocaleString();
    statusIcon.innerText = todo.isComplete ? '✅' : '❌';

    // Tags
    tagsContainer.innerText = '';
    todo.tags.forEach(tag => {
        const span = document.createElement('span');
        span.className = 'tag';
        span.innerText = tag.name;
        tagsContainer.appendChild(span);
    });

    // Parent
    if (todo.parentTodo) {
        parentLink.href = `/detail/${todo.parentTodo.id}`;
        parentLink.innerText = todo.parentTodo.title;
        parentContainer.style.display = 'block';
    } else {
        parentContainer.style.display = 'none';
    }

    // Children
    if (todo.childTodos && todo.childTodos.length > 0) {
        childrenContainer.style.display = 'block';
        childrenList.innerText = '';
        todo.childTodos.forEach(child => {
            const div = document.createElement('div');
            div.className = 'child-item';
            
            const status = document.createElement('span');
            status.innerText = child.isComplete ? '✅' : '❌';
            
            const link = document.createElement('a');
            link.href = `/detail/${child.id}`;
            link.innerText = ` ${child.title}`; // Add space for separation

            div.appendChild(status);
            div.appendChild(link);
            childrenList.appendChild(div);
        });
    } else {
        childrenContainer.style.display = 'none';
    }
}

function init() {
    renderNavbar();
    fetchTodo();
}

init();
