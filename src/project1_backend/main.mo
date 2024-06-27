import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";

actor TrustSystem {
  stable var products : [Product] = [];
  stable var orders : [Order] = [];
  stable var balances : [Principal : Nat] = {};

  type Product = {
    id : Nat;
    name : Text;
    description : Text;
    price : Nat;
    supplier : Principal;
    imageHash : Hash.Hash;
    verified : Bool;
  };

  type Order = {
    id : Nat;
    productId : Nat;
    client : Principal;
    status : OrderStatus;
    timestamp : Time.Time;
  };

  // Corrected OrderStatus definition to be a variant type
  type OrderStatus = {
    #Pending;
    #Confirmed;
    #Refunded;
  };

  var nextProductId : Nat = 0;
  var nextOrderId : Nat = 0;

  public shared({caller}) func addProduct(name: Text, description: Text, price: Nat, imageHash: Hash.Hash, verified: Bool) : async Nat {
    let product = {
      id = nextProductId;
      name = name;
      description = description;
      price = price;
      supplier = caller;
      imageHash = imageHash;
      verified = verified;
    };
    products := Array.append<Product>(products, [product]);
    nextProductId += 1;
    Debug.print("Product added: " # name);
    return product.id;
  };

  public shared({caller}) func placeOrder(productId: Nat) : async Bool {
    let productOpt = findProduct(productId);
    switch (productOpt) {
      case (null) { return false };
      case (?product) {
        let order = {
          id = nextOrderId;
          productId = productId;
          client = caller;
          status = #Pending;
          timestamp = Time.now();
        };
        orders := Array.append<Order>(orders, [order]);
        balances.put(product.supplier, (balances.get(product.supplier) # 0) + product.price);
        nextOrderId += 1;
        Debug.print("Order placed: " # Nat.toText(order.id));
        return true;
      };
    };
  };

  public shared({caller}) func confirmOrder(orderId: Nat) : async Bool {
    let orderOpt = findOrder(orderId);
    switch (orderOpt) {
      case (null) { return false };
      case (?order) {
        if (order.client == caller) {
          order.status := #Confirmed;
          Debug.print("Order confirmed: " # Nat.toText(order.id));
          return true;
        } else {
          return false;
        };
      };
    };
  };

  public shared({caller}) func refundOrder(orderId: Nat) : async Bool {
    let orderOpt = findOrder(orderId);
    switch (orderOpt) {
      case (null) { return false };
      case (?order) {
        if (order.client == caller) {
          order.status := #Refunded;
          let productOpt = findProduct(order.productId);
          switch (productOpt) {
            case (null) { return false };
            case (?product) {
              let currentBalance = balances.get(product.supplier) # 0;
              if (currentBalance >= product.price) {
                balances.put(product.supplier, currentBalance - product.price);
                Debug.print("Order refunded: " # Nat.toText(order.id));
                return true;
              } else {
                return false;
              };
            };
          };
        } else {
          return false;
        };
      };
    };
  };

  public shared({caller}) func checkBalance() : async Nat {
    return balances.get(caller) # 0;
  };

  private func findProduct(productId: Nat) : ?Product {
    for (product in products.vals()) {
      if (product.id == productId) {
        return ?product;
      };
    };
    return null;
  };
};
