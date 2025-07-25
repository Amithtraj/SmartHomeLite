
# Contributing to SmartHomeLite

Welcome! We're excited you're interested in contributing to **SmartHomeLite** 🎉

This lightweight smart home controller project runs on Android using Termux, Python, and FastAPI. Whether you're fixing bugs, improving documentation, or writing new features, your contributions are appreciated.

## 🚀 How to Contribute

### 1. Fork the Repo
Click the **Fork** button on the top right of the [main repo](https://github.com/Amithtraj/SmartHomeLite) page.

### 2. Clone Your Fork Locally
```bash
git clone https://github.com/Amithtraj/SmartHomeLite.git
cd SmartHomeLite
```

### 3. Create a Branch
```bash
git checkout -b my-feature-branch
```

### 4. Make Your Changes
Follow the project structure and write clean, well-commented code. If needed, install requirements via:
```bash
pip install -r requirements.txt
```

### 5. Push and Create a Pull Request
```bash
git push origin my-feature-branch
```

Go to your forked repo and click “Compare & pull request”.

---

## 🧪 Running the App in Termux

1. Install Termux from [F-Droid](https://f-droid.org/en/packages/com.termux/)
2. Install dependencies:
```bash
pkg install python git
pip install fastapi uvicorn pybluez
```

3. Run the API:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

## 💡 Tips

- Keep PRs small and focused
- Use `good first issue` if you're a beginner
- Always follow the code style and project architecture

Thanks for contributing! 💜
