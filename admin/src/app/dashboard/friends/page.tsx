'use client';

import { useRequireAuth } from '@/hooks/useRequireAuth';
import { useState, useEffect } from 'react';
import { apiClient } from '@/lib/api';

interface Friend {
  id: string;
  userId: string;
  friendId: string;
  status: string;
  createdAt: string;
  user: { username: string };
  friend: { username: string };
}

export default function Friends() {
  const { user } = useRequireAuth();
  const [friends, setFriends] = useState<Friend[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [friendId, setFriendId] = useState('');
  const [isAdding, setIsAdding] = useState(false);

  useEffect(() => {
    const fetchFriends = async () => {
      try {
        const data = await apiClient.getFriends();
        setFriends(data);
      } catch (err) {
        setError('Failed to load friends');
      } finally {
        setIsLoading(false);
      }
    };

    fetchFriends();
  }, []);

  const handleAddFriend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!friendId.trim()) return;

    setIsAdding(true);
    try {
      await apiClient.sendFriendRequest({ friendId: friendId.trim() });
      setFriendId('');
      // Refresh friends
      const data = await apiClient.getFriends();
      setFriends(data);
    } catch (err) {
      setError('Failed to send friend request');
    } finally {
      setIsAdding(false);
    }
  };

  const handleAcceptFriend = async (friendId: string) => {
    try {
      await apiClient.acceptFriendRequest({ friendId });
      // Refresh friends
      const data = await apiClient.getFriends();
      setFriends(data);
    } catch (err) {
      setError('Failed to accept friend request');
    }
  };

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">Friends</h1>
            </div>
            <div className="flex items-center space-x-4">
              <a href="/dashboard" className="text-blue-600 hover:text-blue-500">Back to Dashboard</a>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {/* Add Friend Form */}
        <div className="bg-white shadow rounded-lg mb-6">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">Add Friend</h3>
            <form onSubmit={handleAddFriend} className="flex space-x-4">
              <input
                type="text"
                value={friendId}
                onChange={(e) => setFriendId(e.target.value)}
                placeholder="Enter Friend ID"
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                type="submit"
                disabled={isAdding}
                className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50"
              >
                {isAdding ? 'Adding...' : 'Add Friend'}
              </button>
            </form>
          </div>
        </div>

        {error && (
          <div className="mb-4 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded">
            {error}
          </div>
        )}

        {isLoading ? (
          <div className="flex justify-center">
            <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="bg-white shadow overflow-hidden sm:rounded-md">
            <ul className="divide-y divide-gray-200">
              {friends.length === 0 ? (
                <li className="px-6 py-4 text-center text-gray-500">
                  No friends found
                </li>
              ) : (
                friends.map((friend) => (
                  <li key={friend.id} className="px-6 py-4">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center">
                          <div className="flex-shrink-0">
                            <div className="w-10 h-10 bg-purple-500 rounded-full flex items-center justify-center">
                              <span className="text-white">👥</span>
                            </div>
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">
                              {friend.user.username === user.username ? friend.friend.username : friend.user.username}
                            </div>
                            <div className="text-sm text-gray-500">
                              Status: {friend.status} • Added {new Date(friend.createdAt).toLocaleDateString()}
                            </div>
                          </div>
                        </div>
                      </div>
                      {friend.status === 'pending' && friend.friendId === user.id && (
                        <button
                          onClick={() => handleAcceptFriend(friend.userId)}
                          className="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
                        >
                          Accept
                        </button>
                      )}
                    </div>
                  </li>
                ))
              )}
            </ul>
          </div>
        )}
      </main>
    </div>
  );
}
