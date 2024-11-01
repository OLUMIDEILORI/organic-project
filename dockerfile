# Use the latest official Python runtime as a parent image
FROM python:latest

# Set the working directory
WORKDIR /usr/src/app

# Copy requirements.txt
COPY requirements.txt ./

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Define environment variable
ENV DJANGO_SETTINGS_MODULE=myproject.settings

# Run migrations
RUN python manage.py migrate

# Run manage.py to start the server (consider using Gunicorn for production)
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "myproject.wsgi:application"]
