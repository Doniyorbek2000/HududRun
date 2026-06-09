'use client';

import { useRequireAuth } from '@/hooks/useRequireAuth';
import { useState, useEffect } from 'react';
import { apiClient } from '@/lib/api';

interface Activity {
  id: string;
  distance: number;
  duration: number;
  startTime: string;
  endTime?: string;
  route?: any;
}

export default function Activities() {
  const { user } = useRequireAuth();
  const [activities, setActivities] = useState<Activity[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchActivities = async () => {
      try {
        const data = await apiClient.getActivities();
        setActivities(data);
      } catch (err) {
        setError('Failed to load activities');
      } finally {
        setIsLoading(false);
      }
    };

    fetchActivities();
  }, []);

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
              <h1 className="text-2xl font-bold text-gray-900">Activities</h1>
            </div>
            <div className="flex items-center space-x-4">
              <a href="/dashboard" className="text-blue-600 hover:text-blue-500">Back to Dashboard</a>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
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
              {activities.length === 0 ? (
                <li className="px-6 py-4 text-center text-gray-500">
                  No activities found
                </li>
              ) : (
                activities.map((activity) => (
                  <li key={activity.id} className="px-6 py-4">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center">
                          <div className="flex-shrink-0">
                            <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center">
                              <span className="text-white">🏃</span>
                            </div>
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">
                              Activity #{activity.id.slice(-8)}
                            </div>
                            <div className="text-sm text-gray-500">
                              {new Date(activity.startTime).toLocaleString()}
                              {activity.endTime && ` - ${new Date(activity.endTime).toLocaleString()}`}
                            </div>
                          </div>
                        </div>
                      </div>
                      <div className="flex flex-col items-end text-sm text-gray-900">
                        <div>{activity.distance.toFixed(2)} km</div>
                        <div>{Math.round(activity.duration / 60)} min</div>
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
