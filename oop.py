#  Assignment 1: Design Your Own Class

class Smartphone:
    def __init__(self, brand, model, battery=100):
        self.brand = brand
        self.model = model
        self.__battery = battery   # encapsulated (private) attribute

    def use(self, hours):
        """Simulate phone usage by draining battery."""
        drain = hours * 10
        if self.__battery - drain >= 0:
            self.__battery -= drain
        else:
            self.__battery = 0
        print(f"{self.brand} {self.model} used for {hours}h. Battery now at {self.__battery}%.")

    def charge(self):
        """Recharge the phone to 100%."""
        self.__battery = 100
        print(f"{self.brand} {self.model} is fully charged .")

    def get_battery(self):
        """Getter method for encapsulated battery."""
        return self.__battery


# Child class (inheritance + polymorphism)
class GamingPhone(Smartphone):
    def __init__(self, brand, model, gpu, battery=100):
        super().__init__(brand, model, battery)
        self.gpu = gpu

    def play_game(self, game):
        """Special method for gaming phones."""
        print(f"Playing {game}  on {self.brand} {self.model} with {self.gpu} GPU!")
        self.use(2)  # Gaming drains more battery


# Example usage for Assignment 1
print("=== Assignment 1: Smartphone Classes ===")
phone1 = Smartphone("Samsung", "Galaxy S23")
phone2 = GamingPhone("Asus", "ROG Phone 7", "Adreno 730")

phone1.use(3)          # Normal phone usage
phone2.play_game("PUBG")  # Gaming phone special method
print("Battery left on gaming phone:", phone2.get_battery())
print()


#  Activity 2: Polymorphism Challenge

class Vehicle:
    def move(self):
        raise NotImplementedError("Subclass must implement this method")


class Car(Vehicle):
    def move(self):
        print("Driving ")


class Plane(Vehicle):
    def move(self):
        print("Flying ")


class Boat(Vehicle):
    def move(self):
        print("Sailing ")


class Bicycle(Vehicle):
    def move(self):
        print("Pedaling ")


# Example usage for Activity 2
print("=== Activity 2: Polymorphism Challenge ===")
vehicles = [Car(), Plane(), Boat(), Bicycle()]

for v in vehicles:
    v.move()   # Same method name, different outputs (polymorphism!)
