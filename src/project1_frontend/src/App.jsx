// src/App.js
import React, { useState, useEffect } from 'react';
import { trustSystem } from './agent';
import { initIdentity } from './identity';

function App() {
  const [products, setProducts] = useState([]);
  const [orders, setOrders] = useState([]);
  const [message, setMessage] = useState('');
  const [balance, setBalance] = useState(0);
  const [identity, setIdentity] = useState(null);

  useEffect(() => {
    const fetchIdentity = async () => {
      const authClient = await initIdentity();
      setIdentity(authClient.getIdentity());
    };
    fetchIdentity();
  }, []);

  useEffect(() => {
    if (identity) {
      // Fetch balance on load
      const fetchBalance = async () => {
        const result = await trustSystem.checkBalance();
        setBalance(result);
      };
      fetchBalance();
    }
  }, [identity]);

  const addProduct = async (name, description, price, imageHash, verified) => {
    try {
      const productId = await trustSystem.addProduct(name, description, price, imageHash, verified);
      setProducts([...products, { id: productId, name, description, price, imageHash, verified }]);
      setMessage('Product added successfully!');
    } catch (error) {
      setMessage(`Error: ${error.message}`);
    }
  };

  const placeOrder = async (productId) => {
    try {
      const result = await trustSystem.placeOrder(productId);
      if (result) {
        setMessage('Order placed successfully!');
      } else {
        setMessage('Order placement failed.');
      }
    } catch (error) {
      setMessage(`Error: ${error.message}`);
    }
  };

  const confirmOrder = async (orderId) => {
    try {
      const result = await trustSystem.confirmOrder(orderId);
      if (result) {
        setMessage('Order confirmed successfully!');
      } else {
        setMessage('Order confirmation failed.');
      }
    } catch (error) {
      setMessage(`Error: ${error.message}`);
    }
  };

  const refundOrder = async (orderId) => {
    try {
      const result = await trustSystem.refundOrder(orderId);
      if (result)
