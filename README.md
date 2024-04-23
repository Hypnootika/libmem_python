# libmem_python

**libmem_python** provides unofficial Python bindings for Libmem, utilizing nimpy to bridge Python with the powerful memory manipulation capabilities of Libmem. This project allows Python developers to leverage Libmem's features directly from Python scripts.

## Prerequisites

Before you can build and use **libmem_python**, you'll need to have Python and Nim installed on your system. Ensure that you have the following:

- Python (3.10 or newer)
- Nim (2.0.0 or newer)
- nimpy package (nimble install nimpy)

## Installation

Follow these steps to build and install the **libmem_python** bindings:

### 1. Clone the repository

First, clone the **libmem_python** repository to your local machine:

```bash
git clone https://github.com/Hypnootika/libmem_python.git
cd libmem_python
```

### 2. Run Nimble Tasks
Use Nimble, Nim's package manager, to perform the necessary build tasks:

# Download libmem source code
This task fetches the latest source code for Libmem:
```bash
nimble downloadlibmem
```

# Generate Python bindings
This task generates the necessary Nim to Python bindings:
```bash
nimble generatebindings
```

# Build the package
This combines the download and generation tasks and prepares the final package:
```bash
nimble buildall
```

### 3. Build Python Package
After running the Nimble tasks, use Python's setup tools to build the Python package:
```bash
python setup.py sdist bdist_wheel
```

Alternatively use the current Release

### Usage
After installation, you can import libmem_python in your Python scripts to start manipulating memory directly from Python.

### Contributing
Contributions to libmem_python are welcome! Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests to us.

### License
This project is licensed under the MIT License - see the LICENSE file for details.

### Acknowledgments
Thanks to the Libmem developers for their excellent memory manipulation library.
This project uses Nimpy to create bindings, a powerful tool for interfacing Nim with Python.
