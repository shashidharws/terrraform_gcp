provider "google" {
    credentials = "${file("terraform-automation-712de37d392e.json")}"
    project = "terraform-automation-253614"
    region  = "asia-south1"
    zone    = "asia-south1-a"
}

resource "random_id" "instance_id" {
     byte_length = 8
}

resource "google_compute_firewall" "default" {
     name    = "flask-app-firewall"
      network = "default"

       allow {
              protocol = "tcp"
                 ports    = ["5000"]
                  }
}

resource "google_compute_instance" "vm_instance" {
        name = "terraform-instance-${random_id.instance_id.hex}"
        machine_type = "f1-micro"

        boot_disk {
            initialize_params {
                image = "debian-cloud/debian-9"
            }
        }

        #Below: Its a start up script for your instance. start up script runs everytime the instance is created. 
        #the startup script statements are written in single line enclosed in "" 
        #We are installing pip, python and python package flask. flask is imported in the http server code.
        metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"
        metadata = {
            ssh-keys = "shashi:${file("~/.ssh/id_rsa.pub")}"
        }


        network_interface {
            # A default network is created for all GCP projects
            network = "default" 
            # "${google_compute_network.vpc_network.self_link}"
            access_config {
            }
        }

}

output "ip" {
    value = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
}


resource "google_compute_network" "vpc_network" {
      name = "terraform-network"
      auto_create_subnetworks = "true"
}

