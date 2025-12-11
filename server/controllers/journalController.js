export const createJournal = async (req, res) => {
  // Implement saving to DB
  res.json({ status: "success", message: "Journal created" });
};

export const getJournals = async (req, res) => {
  // Implement fetching from DB
  res.json({ status: "success", data: [] });
};
