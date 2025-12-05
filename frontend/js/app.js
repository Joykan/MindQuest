// ---------------- JacClient ----------------
class JacClient {
    constructor(baseUrl = 'http://localhost:8000') {
        this.baseUrl = baseUrl;
        this.graphId = null;
        this.userId = null;
    }

    async init() {
        try {
            const response = await fetch(`${this.baseUrl}/js/walker_run`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `token ${this.getToken()}`
                },
                body: JSON.stringify({ name: 'init', ctx: {}, nd: 'root' })
            });
            const data = await response.json();
            this.graphId = data.report?.[0]?.jid || data.report?.[0]?.id || null;
            return { success: !!this.graphId, graphId: this.graphId };
        } catch (err) {
            console.error("Jac init error:", err);
            return { success: false, error: err.message };
        }
    }

    async spawn(walkerName, context = {}) {
        try {
            const response = await fetch(`${this.baseUrl}/js/walker_run`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `token ${this.getToken()}`
                },
                body: JSON.stringify({
                    name: walkerName,
                    ctx: context,
                    nd: this.graphId || 'root',
                    snt: 'active:graph'
                })
            });
            const data = await response.json();
            return { success: true, report: data.report || [], final_node: data.final_node };
        } catch (err) {
            console.error(`Spawn error ${walkerName}:`, err);
            return { success: false, error: err.message };
        }
    }

    async createUser(name, email) {
        const result = await this.spawn('api_create_user', { name, email });
        if (result.success && result.report.length > 0) {
            this.userId = result.report[0].jid || result.report[0].id;
            localStorage.setItem('mindquest_user_id', this.userId);
            return { success: true, userId: this.userId };
        }
        return { success: false, error: 'Failed to create user' };
    }

    getToken() {
        let token = localStorage.getItem('jaseci_token');
        if (!token) {
            token = 'demo_token';
            localStorage.setItem('jaseci_token', token);
        }
        return token;
    }

    setUserId(userId) { this.userId = userId; localStorage.setItem('mindquest_user_id', userId); }
    getUserId() { return this.userId || localStorage.getItem('mindquest_user_id'); }

    // Add other Jac methods here (logMood, getEmotions, logActivity, etc.)
}

// ---------------- Gemini Chat ----------------
async function sendChatMessage(message) {
    if (!message.trim()) return;

    appendChatMessage("You", message);

    try {
        const res = await fetch("http://localhost:4000/api/chat", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message })
        });

        const data = await res.json();
        const reply = data.reply || "No reply received.";

        appendChatMessage("MindQuest", reply);
    } catch (err) {
        console.error("Chat send error:", err);
        appendChatMessage("MindQuest", "Failed to get response. Check backend.");
    }
}

function appendChatMessage(sender, message) {
    const container = document.getElementById("chat-box");
    const el = document.createElement("div");
    el.className = "chat-message";
    el.innerHTML = `<strong>${sender}:</strong> ${message}`;
    container.appendChild(el);
    container.scrollTop = container.scrollHeight;
}

// ---------------- Initialization ----------------
const jacClient = new JacClient();
let currentUserId = null;

document.addEventListener('DOMContentLoaded', async () => {
    const initRes = await jacClient.init();
    if (!initRes.success) {
        showMessage("Failed to connect to backend Jac.", "error");
        return;
    }

    currentUserId = jacClient.getUserId();
    if (currentUserId) showUserStatus(`Welcome back! User ID: ${currentUserId}`);

    setupEventListeners();
});

// ---------------- Event Listeners ----------------
function setupEventListeners() {
    document.getElementById("send-btn").addEventListener("click", () => {
        const msgInput = document.getElementById("user-input");
        const message = msgInput.value;
        msgInput.value = "";
        sendChatMessage(message);
    });

    document.getElementById("user-input").addEventListener("keypress", (e) => {
        if (e.key === "Enter") document.getElementById("send-btn").click();
    });

    document.getElementById("create-user-btn")?.addEventListener("click", async () => {
        const name = document.getElementById("user-name")?.value;
        const email = document.getElementById("user-email")?.value;

        if (!name || !email) return showMessage("Enter name & email", "error");

        const res = await jacClient.createUser(name, email);
        if (res.success) {
            currentUserId = res.userId;
            showUserStatus(`Profile created! Welcome, ${name}`);
        } else showMessage("Failed to create user.", "error");
    });

    // Add more event listeners for mood logging, journal, activities etc.
}

// ---------------- UI Helpers ----------------
function showMessage(msg, type = "info") {
    const container = document.getElementById("messages");
    if (!container) return;
    const el = document.createElement("div");
    el.className = `message ${type}`;
    el.textContent = msg;
    container.appendChild(el);
    setTimeout(() => el.remove(), 5000);
}

function showUserStatus(msg) {
    const el = document.getElementById("user-status");
    if (!el) return;
    el.textContent = msg;
    el.classList.remove("hidden");
}
