// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "app/javascript/controllers"
import "bootstrap";
import "popper.js";

function deleteBillingMethod(id) {
    if (confirm("Are you sure you want to delete this billing method?")) {
        fetch(`/delete_billing_method/${id}`, {
            method: "DELETE",
            headers: {
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
            },
        }).then(() => window.location.reload());
    }
}