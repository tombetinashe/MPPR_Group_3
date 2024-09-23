// Fetch files from the GitHub repo and display them
fetch("https://api.github.com/repos/vincentsd/GWAC-MPPR/contents/submissions/")
    .then(response => response.json())
    .then(data => {
        const submissionsDiv = document.getElementById("submissions");
        data.forEach(file => {
            if (file.name.endsWith(".txt")) {
                const fileLink = document.createElement("a");
                fileLink.href = file.download_url;
                fileLink.textContent = file.name;
                submissionsDiv.appendChild(fileLink);
                submissionsDiv.appendChild(document.createElement("br"));
            }
        });
    });

// Highlight the current page in the sidebar menu
const links = document.querySelectorAll('#menu nav ol li a');
links.forEach(link => {
    link.classList.remove('active', 'inactive'); // Reset all links
    link.classList.add('inactive'); // Set all to inactive
});

// Set the current link as active
const currentPage = window.location.pathname.split('/').pop();
links.forEach(link => {
    if (link.getAttribute('href') === currentPage) {
        link.classList.add('active'); // Highlight the current link
        link.classList.remove('inactive'); // Make it fully visible
    }
});

// Modal functionality
const modal = document.getElementById("modal");
const img1 = document.getElementById("img1");
const img2 = document.getElementById("img2");
const modalImg1 = document.getElementById("modalImg1");
const modalImg2 = document.getElementById("modalImg2");
const close = document.getElementById("close");

// Show modal when img1 is clicked
img1.onclick = function() {
    modal.style.display = "block";
    modalImg1.src = img1.src; // Set the src of the modal image 1
}

// Show modal when img2 is clicked
img2.onclick = function() {
    modal.style.display = "block";
    modalImg2.src = img2.src; // Set the src of the modal image 2
}

// Close the modal
close.onclick = function() {
    modal.style.display = "none";
}

// Close modal when clicking outside
window.onclick = function(event) {
    if (event.target == modal) {
        modal.style.display = "none";
    }
}
