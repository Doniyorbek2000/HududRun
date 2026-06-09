'use client';

import { useRequireAuth } from '@/hooks/useRequireAuth';
import { useState, useEffect } from 'react';
import { apiClient } from '@/lib/api';

interface Territory {
  id: string;
  h3Index: string;
  ownerId?: string;
  score: number;
  lastActivity?: string;
}

export default function Territories() {
  const { user } = useRequireAuth();
  const [territories, setTerritories] = useState<Territory[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [claimH3Index, setClaimH3Index] = useState('');
  const [isClaiming, setIsClaiming] = useState(false);

  useEffect(() => {
    const fetchTerritories = async () => {
      try {
        const data = await apiClient.getTerritories();
        setTerritories(data);
      } catch (err) {
        setError('Failed to load territories');
      } finally {
        setIsLoading(false);
      }
    };

    fetchTerritories();
  }, []);

  const handleClaim = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!claimH3Index.trim()) return;

    setIsClaiming(true);
    try {
      await apiClient.claimTerritory({ h3Index: claimH3Index.trim() });
      setClaimH3Index('');
      // Refresh territories
      const data = await apiClient.getTerritories();
      setTerritories(data);
    } catch (err) {
      setError('Failed to claim territory');
    } finally {
      setIsClaiming(false);
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
              <h1 className="text-2xl font-bold text-gray-900">Territories</h1>
            </div>
            <div className="flex items-center space-x-4">
              <a href="/dashboard" className="text-blue-600 hover:text-blue-500">Back to Dashboard</a>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {/* Claim Territory Form */}
        <div className="bg-white shadow rounded-lg mb-6">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">Claim Territory</h3>
            <form onSubmit={handleClaim} className="flex space-x-4">
              <input
                type="text"
                value={claimH3Index}
                onChange={(e) => setClaimH3Index(e.target.value)}
                placeholder="Enter H3 Index"
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                type="submit"
                disabled={isClaiming}
                className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50"
              >
                {isClaiming ? 'Claiming...' : 'Claim'}
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
              {territories.length === 0 ? (
                <li className="px-6 py-4 text-center text-gray-500">
                  No territories found
                </li>
              ) : (
                territories.map((territory) => (
                  <li key={territory.id} className="px-6 py-4">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center">
                          <div className="flex-shrink-0">
                            <div className="w-10 h-10 bg-yellow-500 rounded-full flex items-center justify-center">
                              <span className="text-white">🗺️</span>
                            </div>
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">
                              Territory {territory.h3Index}
                            </div>
                            <div className="text-sm text-gray-500">
                              Owner: {territory.ownerId ? `User ${territory.ownerId.slice(-8)}` : 'Unclaimed'}
                            </div>
                          </div>
                        </div>
                      </div>
                      <div className="flex flex-col items-end text-sm text-gray-900">
                        <div>Score: {territory.score}</div>
                        {territory.lastActivity && (
                          <div>Last Activity: {new Date(territory.lastActivity).toLocaleDateString()}</div>
                        )}
                      </div>
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
