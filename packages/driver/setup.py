from setuptools import setup, find_packages

setup(
    name='flutterenium',
    version='0.1.0',  # Initial release version
    description='A brief description of your package',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/tejHackerDEV/flutterenium',
    author='TejHackerDEV',
    author_email='tejasimha222@gmail.com',
    license='MIT',
    packages=find_packages(),
    install_requires=[
        # List your package dependencies here
        'selenium>=4.23.1,<5.0.0'
    ],
    classifiers=[
        'Programming Language :: Python :: 3.10',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.10',
)
