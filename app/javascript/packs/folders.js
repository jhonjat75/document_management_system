document.addEventListener('DOMContentLoaded', initializeFolderFunctionality);
document.addEventListener('turbolinks:load', initializeFolderFunctionality);
document.addEventListener('turbolinks:render', initializeFolderFunctionality);

function initializeFolderFunctionality() {
  const mainContainer = document.querySelector('.folders-container');
  if (!mainContainer) {
    return;
  }
  
  try {
    removeExistingEventListeners();
    initializeProfileFilters();
    initializeActionMenus();
    initializeCreateModal();
    setupClickOutsideHandlers();
  } catch (error) {
    console.error('Error durante la inicialización:', error);
  }
}

function removeExistingEventListeners() {
  const toggleBtn = document.querySelector('.btn-toggle-filters');
  if (toggleBtn) {
    const newToggleBtn = toggleBtn.cloneNode(true);
    toggleBtn.parentNode.replaceChild(newToggleBtn, toggleBtn);
  }
  
  const filterChips = document.querySelectorAll('.filter-chip');
  filterChips.forEach(chip => {
    const newChip = chip.cloneNode(true);
    chip.parentNode.replaceChild(newChip, chip);
  });
  
  const actionButtons = document.querySelectorAll('.btn-actions');
  actionButtons.forEach(button => {
    const newButton = button.cloneNode(true);
    button.parentNode.replaceChild(newButton, button);
  });
}

function initializeProfileFilters() {
  const filterChips = document.querySelectorAll('.filter-chip');
  const folders = document.querySelectorAll('.folder-card');
  const filters = document.getElementById('profileFilters');
  const toggleBtn = document.querySelector('.btn-toggle-filters i');
  
  if (filterChips.length === 0 || folders.length === 0) return;
  
  if (filters && toggleBtn) {
    filters.style.display = 'block';
    toggleBtn.className = 'fas fa-chevron-down';
    
    toggleBtn.parentElement.addEventListener('click', function(e) {
      e.preventDefault();
      toggleProfileFilters();
    });
  }
  
  filterChips.forEach(chip => {
    chip.addEventListener('click', () => {
      const profileId = chip.dataset.profile;
      
      filterChips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      
      if (profileId === 'all') {
        folders.forEach(folder => {
          folder.style.display = 'block';
          folder.style.opacity = '1';
        });
      } else {
        folders.forEach(folder => {
          const folderProfiles = folder.dataset.profiles.split(',');
          if (folderProfiles.includes(profileId)) {
            folder.style.display = 'block';
            folder.style.opacity = '1';
          } else {
            folder.style.display = 'none';
            folder.style.opacity = '0';
          }
        });
      }
    });
  });
}

function initializeActionMenus() {
  const actionButtons = document.querySelectorAll('.btn-actions');
  
  actionButtons.forEach(button => {
    button.addEventListener('click', (e) => {
      e.stopPropagation();
      toggleActionMenu(button);
    });
  });
}

function toggleActionMenu(button) {
  const menu = button.nextElementSibling;
  const allMenus = document.querySelectorAll('.actions-menu');
  
  allMenus.forEach(m => {
    if (m !== menu) {
      m.classList.remove('show');
    }
  });
  
  menu.classList.toggle('show');
}

function initializeCreateModal() {
  const profileCheckboxes = document.querySelectorAll('.profile-checkbox');
  profileCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      const profileOption = this.closest('.profile-option');
      if (this.checked) {
        profileOption.style.borderColor = '#3b82f6';
        profileOption.style.background = '#eff6ff';
      } else {
        profileOption.style.borderColor = '#e2e8f0';
        profileOption.style.background = '#f8fafc';
      }
    });
  });
  
  const toggleFiltersBtn = document.querySelector('.btn-toggle-filters');
  if (toggleFiltersBtn) {
    toggleFiltersBtn.addEventListener('click', toggleProfileFilters);
  }
}

function toggleProfileFilters() {
  const filters = document.getElementById('profileFilters');
  const toggleBtn = document.querySelector('.btn-toggle-filters i');
  
  if (!filters || !toggleBtn) {
    console.warn('Elementos del filtro no encontrados');
    return;
  }
  
  const isVisible = filters.style.display !== 'none' && filters.style.display !== '';
  
  if (isVisible) {
    filters.style.display = 'none';
    toggleBtn.className = 'fas fa-chevron-down';
  } else {
    filters.style.display = 'block';
    toggleBtn.className = 'fas fa-chevron-up';
  }
}

function setupClickOutsideHandlers() {
  const mainContainer = document.querySelector('.folders-container');
  if (!mainContainer) return;
  
  document.addEventListener('click', handleClickOutside);
}

function handleClickOutside(e) {
  const mainContainer = document.querySelector('.folders-container');
  if (!mainContainer) return;
  
  if (!e.target.closest('.action-dropdown')) {
    document.querySelectorAll('.actions-menu').forEach(menu => {
      menu.classList.remove('show');
    });
  }
  
  if (!e.target.closest('.search-container')) {
    closeSearchResults();
  }
}

window.toggleActionsMenu = toggleActionMenu;
window.toggleProfileFilters = toggleProfileFilters;

document.addEventListener('turbolinks:before-visit', function() {
  const searchResults = document.getElementById('searchResults');
  if (searchResults) {
    searchResults.style.display = 'none';
  }
});

document.addEventListener('turbolinks:before-cache', function() {
  const searchResults = document.getElementById('searchResults');
  if (searchResults) {
    searchResults.style.display = 'none';
  }
});
