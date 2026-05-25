const BASE_URL = "http://localhost:3000";

export const getEmployees = async () => {
  const response = await fetch(`${BASE_URL}/employees`);
  if (!response.ok) {
    throw new Error(`API Error: Status ${response.status}`);
  }
  return await response.json();
};
